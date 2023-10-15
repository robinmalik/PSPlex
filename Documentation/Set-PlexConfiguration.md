---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Set-PlexConfiguration

## SYNOPSIS
Obtains an access token for your account and saves it and your server details.

## SYNTAX

```
Set-PlexConfiguration [-Credential] <PSCredential> [-DefaultServerName] <String> [<CommonParameters>]
```

## DESCRIPTION
Used to save Plex configuration to disk, which is used by all other functions.

## EXAMPLES

### EXAMPLE 1
```
Set-PlexConfiguration -Credential (Get-Credential)
```

## PARAMETERS

### -Credential
Credential object containing your Plex username and password.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DefaultServerName
{{ Fill DefaultServerName Description }}

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
