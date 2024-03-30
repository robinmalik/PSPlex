---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# New-PlexSmartCollection

## SYNOPSIS
Creates a new smart collection.

## SYNTAX

```
New-PlexSmartCollection [-Name] <String> [-LibraryID] <String> [-Filter] <String> [[-MatchType] <String>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new smart collection.

## EXAMPLES

### EXAMPLE 1
```
New-PlexSmartCollection -Name "Star Trek" -LibraryID 1 -Filter "Title Contains Star Trek"
```

### EXAMPLE 2
```
New-PlexSmartCollection -Name "80's" -LibraryID 1 -Filter "Decade Is 1980"
```

### EXAMPLE 3
```
New-PlexSmartCollection -Name "Old Favorites" -LibraryID 1 -Filter "Plays IsGreaterThan 2; LastPlayed IsNotInTheLast 1y"
```

### EXAMPLE 4
```
New-PlexSmartCollection -Name "Trek Wars" -LibraryID 1 -MatchType MatchAny -Filter "title contains star trek; title contains star wars"
```

## PARAMETERS

### -Name
Name of the smart collection.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LibraryID
ID of the library to create the smart collection in.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filter
Specifies the query string that retrieves the items in the smart collection.
The syntax matches the Plex Web GUI as closely as possible.
Clauses are separated by a semi-colon ( ; ).

Syntax:

\<Atttribute\> \<Operator\> \<Value\>
\<Atttribute\> \<Operator\> \<Value\>;\<Atttribute\> \<Operator\> \<Value\>

Attributes:
    - String
        - Title
        - Studio
        - Edition
    - Numeric
        - Rating
        - Year
        - Decade
        - Plays
    - Exact
        - ContentRating
        - Genre
        - Collection
        - Actor
        - Country
        - SubtitleLanguage
        - AudioLanguage
        - Label
    - Boolean
        - Unmatched
        - Duplicate
        - Unplayed
        - HDR
        - InProgress
        - Trash
    - Semi-Boolean
        - Resolution
    - Date
        - ReleaseDate
        - DateAdded
        - LastPlayed

Operators:
    - String
        - Contains
        - DoesNotContain
        - Is
        - IsNot
        - BeginsWith
        - EndsWith
    - Numeric
        - Is
        - IsNot
        - IsGreaterThan
        - IsLessThan
    - Exact
        - Is
        - IsNot
    - Boolean
        - IsTrue
        - IsFalse
    - Semi-Boolean
        - Is
    - Date
        - IsBefore (Value format: yyyy-mm-dd)
        - IsAfter (Value format: yyyy-mm-dd)
        - IsInTheLast
        - IsNotInTheLast

Examples:

    - "DateAdded IsNotInTheLast 2y; Unplayed IsTrue"
    - "Title BeginsWith Star Trek; Unplayed IsTrue"
    - "Actor Is Jim Carrey; Genre Is Comedy"

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MatchType
Specifies how filter clauses are matched.

- MatchAll: Matches all clauses.
- MatchAny: Matches any cluase.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: MatchAll
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
