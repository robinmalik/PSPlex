---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Copy-PlexPlaylist

## SYNOPSIS
This function will copy a playlist from your account to another user account on your server.
Note: If the destination user already has a playlist with this name, a second one will be created.
To overwrite, use the -Force switch.

## SYNTAX

```
Copy-PlexPlaylist [-Id] <String> [[-NewPlaylistName] <String>] [-Username] <String> [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function will copy a playlist from your account to another user account on your server.
Note: If the destination user already has a playlist with this name, a second one will be created.
To overwrite, use the -Force switch.

## EXAMPLES

### EXAMPLE 1
```
Copy-PlexPlaylist -Id 12345 -User 'user@domain.com'
```

## PARAMETERS

### -Id
Id of the playlist you wish to copy.
To get this, use 'Get-PlexPlaylist'.

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

### -NewPlaylistName
Create the playlist with a different name.

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

### -Username
The username for the account you wish to copy the playlist to.

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

### -Force
Overwrite the contents of an existing playlist.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
