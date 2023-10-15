---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Get-PlexPlaylist

## SYNOPSIS
Gets playlists.

## SYNTAX

### All (Default)
```
Get-PlexPlaylist [-IncludeItems] [-AlternativeToken <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### Id
```
Get-PlexPlaylist [-Id <String>] [-IncludeItems] [-AlternativeToken <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Name
```
Get-PlexPlaylist [-Name <String>] [-IncludeItems] [-AlternativeToken <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Gets playlists.

## EXAMPLES

### EXAMPLE 1
```
Get-PlexPlaylist -Id 723 -IncludeItems
```

### EXAMPLE 2
```
$User = Get-PlexUser -Username "friendsusername"
Get-PlexPlaylist -AlternativeToken $User.Token
```

## PARAMETERS

### -Id
The id of the playlist to get.

```yaml
Type: String
Parameter Sets: Id
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
{{ Fill Name Description }}

```yaml
Type: String
Parameter Sets: Name
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeItems
If specified, the items in the playlist are returned.

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

### -AlternativeToken
Alternative token to use for authentication.
For example,
when querying for playlists for a different user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
