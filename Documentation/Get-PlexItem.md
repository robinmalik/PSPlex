---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Get-PlexItem

## SYNOPSIS
Get a specific item.

## SYNTAX

### Id
```
Get-PlexItem -Id <String> [-IncludeTracks] [<CommonParameters>]
```

### Library
```
Get-PlexItem -LibraryTitle <String> [<CommonParameters>]
```

## DESCRIPTION
Get a specific item.

## EXAMPLES

### EXAMPLE 1
```
# Get a single item by Id:
Get-PlexItem -Id 204
```

### EXAMPLE 2
```
# Get all items from the library called 'Films'.
# NOTE: Not all data for an item is returned this way.
$Items = Get-PlexItem -LibraryTitle Films
# Get all data for the above items:
$AllData = $Items | % { Get-PlexItem -Id $_.ratingKey }
```

## PARAMETERS

### -Id
The id of the item.

```yaml
Type: String
Parameter Sets: Id
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeTracks
Only valid for albums.
If specified, the tracks in the album are returned.

```yaml
Type: SwitchParameter
Parameter Sets: Id
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -LibraryTitle
Gets all items from a library with the specified title.

```yaml
Type: String
Parameter Sets: Library
Aliases:

Required: True
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
