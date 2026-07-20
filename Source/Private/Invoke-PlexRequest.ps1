function Invoke-PlexRequest
{
	<#
		.SYNOPSIS
			Internal wrapper for all Plex API HTTP requests.
		.DESCRIPTION
			This function is the single place in the module where Invoke-WebRequest is called.
			It handles PS5.1/PS7 compatibility, TLS setup, UTF-8 decoding, JSON/XML content
			negotiation, and consistent error handling. Token values are redacted from verbose output.
		.PARAMETER RestEndpoint
			Relative endpoint on the default Plex server. The full URI is built from the
			default server's base address, this endpoint and any query parameters.
		.PARAMETER Params
			Hashtable of query parameters for the Endpoint parameter set.
		.PARAMETER Uri
			Absolute URI (e.g. for plex.tv calls). No configuration import is performed and
			no token header is added; the caller is responsible for authentication.
		.PARAMETER Token
			Overrides the default server token when talking to the default Plex server,
			e.g. to make a request as another user. Sent as the X-Plex-Token header.
		.PARAMETER Method
			HTTP method. Defaults to GET.
		.PARAMETER Headers
			Additional headers to merge over the default Accept header.
		.PARAMETER Body
			Request body.
		.PARAMETER ContentType
			Content-Type header value.
		.PARAMETER UserAgent
			User-Agent string to use.
		.PARAMETER OutFile
			Path for binary downloads.
		.PARAMETER Raw
			Return the decoded UTF-8 string without JSON/XML parsing.
		.PARAMETER TimeoutSec
			Request timeout in seconds. Default is 30.
		.EXAMPLE
			Invoke-PlexRequest -RestEndpoint "library/sections" -Params @{ includeDetails = 1 }
		.EXAMPLE
			Invoke-PlexRequest -Uri "https://plex.tv/api/users?X-Plex-Token=abc123" -Method GET
	#>

	[CmdletBinding(DefaultParameterSetName = 'Endpoint')]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'Endpoint')]
		[String]
		$RestEndpoint,

		[Parameter(Mandatory = $false, ParameterSetName = 'Endpoint')]
		[System.Collections.IDictionary]
		$Params,

		[Parameter(Mandatory = $true, ParameterSetName = 'Uri')]
		[String]
		$Uri,

		[Parameter(Mandatory = $false)]
		[String]
		$Token,

		[Parameter(Mandatory = $false)]
		[ValidateSet('GET', 'POST', 'PUT', 'DELETE')]
		[String]
		$Method = 'GET',

		[Parameter(Mandatory = $false)]
		[System.Collections.IDictionary]
		$Headers,

		[Parameter(Mandatory = $false)]
		$Body,

		[Parameter(Mandatory = $false)]
		[String]
		$ContentType,

		[Parameter(Mandatory = $false)]
		[String]
		$UserAgent,

		[Parameter(Mandatory = $false)]
		[String]
		$OutFile,

		[Parameter(Mandatory = $false)]
		[Switch]
		$Raw,

		[Parameter(Mandatory = $false)]
		[Int]
		$TimeoutSec = 30
	)

	#############################################################################
	#Region TLS 1.2 bootstrap for Windows PowerShell 5.1
	if($PSVersionTable.PSEdition -ne 'Core' -and -not $script:PlexTlsConfigured)
	{
		try
		{
			[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
		}
		catch
		{
			# Best-effort; continue and let the actual request report any TLS problem.
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Could not enable TLS 1.2: $($_.Exception.Message)"
		}
		$script:PlexTlsConfigured = $true
	}
	#EndRegion

	#############################################################################
	#Region Build URI and resolve token for the Endpoint parameter set
	if($PSCmdlet.ParameterSetName -eq 'Endpoint')
	{
		if(!$script:PlexConfigData)
		{
			Import-PlexConfiguration
		}

		# Build the request URI from the default server's address, the endpoint and any query parameters.
		$Endpoint = $RestEndpoint.TrimStart('/')
		if($Params -and $Params.Count -gt 0)
		{
			$QueryString = ($Params.GetEnumerator() | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join '&'
			$Uri = "$($script:DefaultPlexServer.Uri)/$($Endpoint)?$($QueryString)"
		}
		else
		{
			$Uri = "$($script:DefaultPlexServer.Uri)/$($Endpoint)"
		}

		# The token travels as a header, not a query parameter. Use an explicit token if one
		# was supplied (e.g. to act as another user), otherwise the default server's token.
		if(!$Token)
		{
			$Token = $script:DefaultPlexServer.Token
		}
	}
	#EndRegion

	#############################################################################
	#Region Build Invoke-WebRequest splat
	$RequestParams = @{
		Uri             = $Uri
		Method          = $Method
		UseBasicParsing = $true
		ErrorAction     = 'Stop'
		TimeoutSec      = $TimeoutSec
		Headers         = @{ 'Accept' = 'application/json, text/plain, */*' }
	}

	if($Token)
	{
		$RequestParams.Headers['X-Plex-Token'] = $Token
	}

	if($Headers)
	{
		foreach($Key in $Headers.Keys)
		{
			$RequestParams.Headers[$Key] = $Headers[$Key]
		}
	}

	if($PSBoundParameters.ContainsKey('Body'))
	{
		$RequestParams.Add('Body', $Body)
	}

	if($ContentType)
	{
		$RequestParams.Add('ContentType', $ContentType)
	}

	if($UserAgent)
	{
		$RequestParams.Add('UserAgent', $UserAgent)
	}

	if($OutFile)
	{
		$RequestParams.Add('OutFile', $OutFile)
	}
	#EndRegion

	#############################################################################
	#Region Redact tokens in verbose output
	$RedactedUri = $Uri -replace '(X-Plex-Token=)[^&]+', '$1<redacted>' -replace '(auth_token=)[^&]+', '$1<redacted>'
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): $Method $RedactedUri"
	#EndRegion

	#############################################################################
	#Region Send request and decode response
	try
	{
		$Response = Invoke-WebRequest @RequestParams

		# If writing to a file, the body is already saved; return nothing.
		if($OutFile)
		{
			return
		}

		# Guard against empty bodies (e.g. 200 OK on PUT/DELETE).
		if($Response.RawContentStream -and $Response.RawContentStream.Length -gt 0)
		{
			$Text = [System.Text.Encoding]::UTF8.GetString($Response.RawContentStream.ToArray())
		}
		else
		{
			return $null
		}

		# If Raw was requested, return the decoded string without parsing.
		if($Raw)
		{
			return $Text
		}

		# Content-type negotiation. Content-Type may be a string or string[] depending on PS edition.
		$ContentTypeHeader = "$(($Response.Headers['Content-Type'] -join ',').ToLower())"

		if($ContentTypeHeader -like '*json*')
		{
			try
			{
				return $Text | ConvertFrom-Json -ErrorAction Stop
			}
			catch
			{
				# Plex JSON sometimes contains keys duplicated with different casing (guid/Guid, rating/Rating),
				# which ConvertFrom-Json cannot handle. Rename the lowercase keys and retry.
				$Fixed = $Text.Replace('"guid"', '"_guid"').Replace('"rating"', '"_rating"')
				return $Fixed | ConvertFrom-Json -ErrorAction Stop
			}
		}
		elseif(($ContentTypeHeader -like '*xml*') -or ($Text.TrimStart().StartsWith('<')))
		{
			return [xml]$Text
		}
		else
		{
			return $Text
		}
	}
	catch
	{
		$StatusCode = $null
		$ResponseBody = $null

		if($_.Exception.PSObject.Properties['Response'] -and $_.Exception.Response)
		{
			$StatusCode = [int]$_.Exception.Response.StatusCode
			if($_.ErrorDetails.Message)
			{
				$ResponseBody = $_.ErrorDetails.Message
			}
			elseif($_.Exception.Response -is [System.Net.HttpWebResponse])
			{
				$Stream = $_.Exception.Response.GetResponseStream()
				if($Stream)
				{
					$Reader = New-Object System.IO.StreamReader($Stream)
					$ResponseBody = $Reader.ReadToEnd()
					$Reader.Dispose()
				}
			}
		}

		$Message = "Plex API request failed: $Method $RedactedUri"
		if($StatusCode)
		{
			$Message += " - HTTP $StatusCode"
			if($ResponseBody)
			{
				$Message += ": $ResponseBody"
			}
			if($StatusCode -eq 401)
			{
				$Message += ". Your token may be invalid or expired. Re-run Set-PlexConfiguration."
			}
		}
		else
		{
			$Message += ": $($_.Exception.Message)"
		}

		$Exception = [System.Exception]::new($Message, $_.Exception)
		$ErrorRecord = [System.Management.Automation.ErrorRecord]::new(
			$Exception,
			'PlexApiRequestFailed',
			[System.Management.Automation.ErrorCategory]::InvalidOperation,
			$RedactedUri
		)
		$PSCmdlet.ThrowTerminatingError($ErrorRecord)
	}
	#EndRegion
}
