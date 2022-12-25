---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Add-PlexLabel

## SYNOPSIS
Adds a label to a Plex item (movie, show, or album).

## SYNTAX

```
Add-PlexLabel [-Id] <String> [-Label] <String> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Labels attached on movies, shows or albums are useful when sharing
library content with others; you can choose to only show items with
specific labels, or to hide items with specific labels.

## EXAMPLES

### EXAMPLE 1
```
Add-PlexLabel -Id 12345 -Label 'FLAC'
```

## PARAMETERS

### -Id
Id of the item to add the label to.

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

### -Label
The label to add.

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
Only movies, shows and albums support labels.

## RELATED LINKS
