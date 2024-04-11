---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Get-PlexCollection

## SYNOPSIS
Gets collections.

## SYNTAX

### CollectionId
```
Get-PlexCollection -Id <PSObject> [-IncludeItems] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### LibraryId
```
Get-PlexCollection -LibraryId <PSObject> [-IncludeItems] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Gets collections.

## EXAMPLES

### EXAMPLE 1
```
Get-PlexCollection -LibraryId 1
```

### EXAMPLE 2
```
Get-PlexCollection -Id 723 -IncludeItems
```

### EXAMPLE 3
```
# Get all collections from library 1 with the name, id (ratingkey) and number of items in the collection:
Get-PlexCollection -LibraryId 1 | Select-Object title,ratingkey,childcount
```

## PARAMETERS

### -Id
The id of the collection to get.

```yaml
Type: PSObject
Parameter Sets: CollectionId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -LibraryId
The id of the library to get collections from.

```yaml
Type: PSObject
Parameter Sets: LibraryId
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeItems
If specified, the items in the collection are returned.

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
