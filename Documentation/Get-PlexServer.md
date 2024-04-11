---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Get-PlexServer

## SYNOPSIS
Returns a list of online Plex Servers that you have access to (remote access must be enabled).

## SYNTAX

```
Get-PlexServer [[-Name] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Returns a list of online Plex Servers that you have access to (remote access must be enabled).

## EXAMPLES

### EXAMPLE 1
```
Get-PlexServer
```

## PARAMETERS

### -Name
{{ Fill Name Description }}

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

### accessToken       : abcd123456ABCDEFG
### name              : thor
### address           : 87.50.66.123
### port              : 32400
### version           : 1.16.0.1226-7eb2c8f6f
### scheme            : http
### host              : 87.50.66.123
### localAddresses    : 172.18.0.2
### machineIdentifier : 8986j4286yl055szhtjx1bytgibsgpv93neb8yv4
### createdAt         : 1550665837
### updatedAt         : 1562328805
### owned             : 1
### synced            : 0
### accessToken       : HIJKLMNO098765431
### name              : friendserver
### address           : 94.12.145.10
### port              : 32400
### version           : 1.16.1.1291-158e5b199
### scheme            : http
### host              : 94.12.145.10
### localAddresses    :
### machineIdentifier : 534vgrzhrrp47oojircfdz9qxeqav4gkmqqnu1at
### createdAt         : 1520613024
### updatedAt         : 1562330172
### owned             : 0
### synced            : 0
### sourceTitle       : username_of_friend
### ownerId           : 6728195
### home              : 0
## NOTES

## RELATED LINKS
