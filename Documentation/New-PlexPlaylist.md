---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# New-PlexPlaylist

## SYNOPSIS
Creates a new playlist.

## SYNTAX

```
New-PlexPlaylist [-Name] <String> [-Type] <String> [-Id] <String[]> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates a new playlist.

## EXAMPLES

### EXAMPLE 1
```
New-PlexPlaylist -Name "My Playlist" -Type video -Id 123,456,789
```

### EXAMPLE 2
```
$Item = Find-PlexItem -Name "Some Movie"
New-PlexPlaylist -Name "My Playlist" -Type video -Id $Item.ratingKey
```

## PARAMETERS

### -Name
Name of the playlist.

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

### -Type
Type of playlist.
Currently only 'video' is supported.

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

### -Id
IDs of the Plex items to add.
Can be an array or comma separated list.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
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
