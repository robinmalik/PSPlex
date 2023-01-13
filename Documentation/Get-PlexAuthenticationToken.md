---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Get-PlexAuthenticationToken

## SYNOPSIS
Gets the authentication token from Plex.tv for your account.

## SYNTAX

```
Get-PlexAuthenticationToken [[-Credential] <PSCredential>] [<CommonParameters>]
```

## DESCRIPTION
Gets the authentication token from Plex.tv for your account.
Creates a script scoped variable that is used by the other functions.

## EXAMPLES

### EXAMPLE 1
```
Get-PlexAuthenticationToken -Credential (Get-Credential)
```

## PARAMETERS

### -Credential
A PScredential object (usually obtained by running Get-Credential).

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
