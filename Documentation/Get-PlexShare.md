---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Get-PlexShare

## SYNOPSIS
Gets a user and the share status of your libraries with them.

## SYNTAX

### username
```
Get-PlexShare [-Username <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### email
```
Get-PlexShare [-Email <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Gets a user and the share status of your libraries with them.

## EXAMPLES

### EXAMPLE 1
```
Get-PlexShare -Username "username"
```

### EXAMPLE 2
```
# Get share status for a single user:
Get-PlexShare -Username "username" | Select -ExpandProperty section
```

### EXAMPLE 3
```
# Get share status for all users:
Get-PlexUser | Select username | % { Get-PlexShare -Username $_.username }
```

## PARAMETERS

### -Username
The username of the user to query share status.

```yaml
Type: String
Parameter Sets: username
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Email
The email address of the user to query share status.

```yaml
Type: String
Parameter Sets: email
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

### username allowSync section                                 invitedAt
### -------- --------- -------                                 ---------
### person1  1         {Section, Section, Section, Section...} 16/01/2022 19:01:39
### person2  0         {Section, Section, Section, Section...} 08/01/2022 20:15:31
## NOTES

## RELATED LINKS
