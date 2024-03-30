function Resolve-PlexFilter
{
    <#
        .SYNOPSIS
            Parses filter string into Plex API query.
        .DESCRIPTION
            Parses filter string into Plex API query. Filter syntax is '<Attribute> <Operator> <Value>'. Clauses are separated by semi-colons (;)
        .EXAMPLE
            Resolve-PlexFilter -MatchAll -Filter "Title BeginsWith Star Trek; Unplayed IsTrue"
        .EXAMPLE
            Resolve-PlexFilter -MatchAny -Filter "DateAdded IsNotInTheLast 2y; Unplayed IsTrue"
        .EXAMPLE
            Resolve-PlexFilter -MatchAll -Filter "Decade IsLessThan 1990s"
	#>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'MatchAny')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'MatchAll')]

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Filter,

        [Parameter(ParameterSetName = "All")]
        [switch]
        $MatchAll,

        [Parameter(ParameterSetName = "Any")]
        [switch]
        $MatchAny
    )

    # Copied from Plex web GUI.
    # @{Class = @{Operator1, Operator2...}}
    $Operators = @{
        String   = @{
            Contains       = "="
            DoesNotContain = "!="
            Is             = "=="
            IsNot          = "!=="
            BeginsWith     = "<="
            EndsWith       = ">="
        }
        Numeric  = @{
            Is            = "="
            IsNot         = "!="
            IsGreaterThan = ">>="
            IsLessThan    = "<<="
        }
        Exact    = @{
            Is    = "="
            IsNot = "!="
        }
        Bool     = @{
            IsTrue  = "=1"
            IsFalse = "!=1"
        }
        SemiBool = @{
            Is = "="
        }
        Date     = @{
            IsBefore       = "<<="
            IsAfter        = ">>="
            IsInTheLast    = ">>=-"
            IsNotInTheLast = "<<=-"
        }
    }

    # Copied from Plex web GUI and translated into Plex DB attributes.
    $Attributes = @{
        Title            = @{ Class = "String" ; Name = "title" }
        Studio           = @{ Class = "String" ; Name = "studio" }
        Edition          = @{ Class = "String" ; Name = "editionTitle" }
        Rating           = @{ Class = "Numeric" ; Name = "userRating" }
        Year             = @{ Class = "Numeric" ; Name = "year" }
        Decade           = @{ Class = "Numeric" ; Name = "decade" }
        Plays            = @{ Class = "Numeric" ; Name = "viewCount" }
        ContentRating    = @{ Class = "Exact" ; Name = "contentRating" }
        Genre            = @{ Class = "Exact" ; Name = "genre" }
        Collection       = @{ Class = "Exact" ; Name = "collection" }
        Director         = @{ Class = "Exact" ; Name = "director" }
        Writer           = @{ Class = "Exact" ; Name = "writer" }
        Producer         = @{ Class = "Exact" ; Name = "producer" }
        Actor            = @{ Class = "Exact" ; Name = "actor" }
        Country          = @{ Class = "Exact" ; Name = "country" }
        SubtitleLanguage = @{ Class = "Exact" ; Name = "subtitleLanguage" }
        AudioLanguage    = @{ Class = "Exact" ; Name = "audioLanguage" }
        Label            = @{ Class = "Exact" ; Name = "label" }
        Unmatched        = @{ Class = "Bool" ; Name = "unmatched" }
        Duplicate        = @{ Class = "Bool" ; Name = "duplicate" }
        Unplayed         = @{ Class = "Bool" ; Name = "unwatched" }
        HDR              = @{ Class = "Bool" ; Name = "hdr" }
        InProgress       = @{ Class = "Bool" ; Name = "inProgress" }
        Trash            = @{ Class = "Bool" ; Name = "trash" }
        Resolution       = @{ Class = "SemiBool" ; Name = "resolution" }
        ReleaseDate      = @{ Class = "Date" ; Name = "originallyAvailableAt" }
        DateAdded        = @{ Class = "Date" ; Name = "addedAt" }
        LastPlayed       = @{ Class = "Date" ; Name = "lastViewedAt" }
    }

    try
    {
        $Query = foreach ($Clause in ($Filter -split ';'))
        {
            # Parse out values from clause
            if (-not ($Clause -match '(?<Attribute>\w+) (?<Operator>\w+)(?: (?<Value>.*))?'))
            {
                throw "Unable to parse filter clause '$Clause'. Syntax is '<Attribute> <Operator> <Value>'."
            }

            # Translate clause into API query and verify that it makes sense.
            $Attribute = $Attributes[$Matches.Attribute]
            $Operator = $Operators[$Attribute.Class].($Matches.Operator)
            if (-not $Attribute)
            {
                throw "Unable to parse filter clause '$Clause'. Attribute does not exist in Plex DB."
            }
            if (-not $Operator)
            {
                throw "Unable to parse filter clause '$Clause'. Operator not supported by the attribute."
            }

            #TODO translate Exact class into Plex DB ratingKey

            # Return API query
            $Attribute.Name, $Operator, $Matches.Value -join ''
        }

        # Return entire API query
        switch ($PSCmdlet.ParameterSetName)
        {
            "All" { $Query -join '&' ; continue }
            "Any" { "push=1&{0}&pop=1" -f ($Query -join '&') ; continue }
            default { throw "You should not see this." }
        }
    }
    catch
    {
        if ($_.Exception.Message -match "Index operation failed")
        {
            throw "Unable to parse filter clause '$Clause'."
        }
        else { $PSCmdlet.ThrowTerminatingError($_) }
    }
}