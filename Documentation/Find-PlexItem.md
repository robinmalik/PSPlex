---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Find-PlexItem

## SYNOPSIS
This function uses the search ability of Plex find items on your Plex server.

## SYNTAX

```
Find-PlexItem [-ItemName] <String> [[-ItemType] <String>] [[-LibraryTitle] <String>] [[-Year] <Int32>]
 [-ExactNameMatch] [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function uses the search ability of Plex find items on your Plex server.
As objects returned have different properties depending on the type, there is
an option to refine this by type.

## EXAMPLES

### EXAMPLE 1
```
# Find only 'movies' from the Plex server that (fuzzy)match 'The Dark Knight'.
Find-PlexItem -ItemName 'The Dark Knight' -ItemType 'movie'
```

### EXAMPLE 2
```
# Find items that match exactly 'The Dark Knight' from the library 'Films'.
Find-PlexItem -ItemName 'The Dark Knight' -ExactNameMatch -LibraryTitle 'Films'
```

### EXAMPLE 3
```
# Find items that (fuzzy)match 'Spider' from the library 'TV'.
Find-PlexItem -ItemName 'spider' -LibraryTitle 'TV'
```

## PARAMETERS

### -ItemName
Name of what you wish to find.

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

### -ItemType
Refines the output by type.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LibraryTitle
{{ Fill LibraryTitle Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Year
Refine by year.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExactNameMatch
Return only items matching exactly what is specified as ItemName.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

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
