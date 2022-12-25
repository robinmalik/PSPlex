---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Save-PlexConfiguration

## SYNOPSIS
After executing 'Get-PlexAuthenticationToken', save your configuration to disk.

## SYNTAX

### TokenFromGetPlexAuthenticationToken (Default)
```
Save-PlexConfiguration -PlexServer <String> -PlexServerHostname <String> -Protocol <String> [-Port <Int32>]
 [-Default] [<CommonParameters>]
```

### TokenFromCommandLine
```
Save-PlexConfiguration -PlexServer <String> -PlexServerHostname <String> -Protocol <String> [-Port <Int32>]
 [-Username <String>] [-Token <String>] [-Default] [<CommonParameters>]
```

## DESCRIPTION
After executing 'Get-PlexAuthenticationToken', save your configuration to disk.

## EXAMPLES

### EXAMPLE 1
```
Save-PlexConfiguration -PlexServer myserver -PlexServerHostname namaste.yourdomain.com -Protocol https -Port 32400
```

## PARAMETERS

### -PlexServer
The name of the Plex server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PlexServerHostname
The fully qualified hostname for your server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Protocol
The protocol (http/https)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Port
The port (usually 32400)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 32400
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
Specify the username manually (if not running 'Get-PlexAuthenticationToken')

```yaml
Type: String
Parameter Sets: TokenFromCommandLine
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Token
Specify the token manually (if not running 'Get-PlexAuthenticationToken')

```yaml
Type: String
Parameter Sets: TokenFromCommandLine
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Default
Set the Plex server as the default.
If this is the first time you're saving
configuration it will be marked as the default.

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
