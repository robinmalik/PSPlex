---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Get-PlexUser

## SYNOPSIS
Gets a list of users associated with your account (e.g those you have shared with).

## SYNTAX

```
Get-PlexUser [[-Username] <String>] [-IncludeToken] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Gets a list of users associated with your account (e.g those you have shared with).
This can include users who do not currently have access to libraries.

## EXAMPLES

### EXAMPLE 1
```
Get-PlexUser
```

## PARAMETERS

### -Username
Refine by username (note: all users must be obtained from the Plex API first).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -IncludeToken
Get access token(s) that accounts use to access your server.

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
