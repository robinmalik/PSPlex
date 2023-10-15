Function ConvertFrom-UnixTime($UnixDate)
{
	<#
		.SYNOPSIS
			Converts a Unix timestamp to a DateTime object.
		.DESCRIPTION
			Converts a Unix timestamp to a DateTime object.
		.PARAMETER UnixDate
			The Unix timestamp to convert.
		.EXAMPLE
			ConvertFrom-UnixTime -UnixDate 1234567890
	#>

	[timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($UnixDate))
}