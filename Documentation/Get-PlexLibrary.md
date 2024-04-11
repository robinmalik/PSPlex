---
external help file: PSPlex-help.xml
Module Name: PSPlex
online version:
schema: 2.0.0
---

# Get-PlexLibrary

## SYNOPSIS
By default, returns a list of libraries on a Plex server.

## SYNTAX

### All (Default)
```
Get-PlexLibrary [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Id
```
Get-PlexLibrary [-Id <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Name
```
Get-PlexLibrary [-Name <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
By default, returns a list of libraries on a Plex server.
If -Id is specified, a single library is returned with

## EXAMPLES

### EXAMPLE 1
```
Get-PlexLibrary
```

## PARAMETERS

### -Id
If specified, returns a specific library.

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

## NOTES

## RELATED LINKS
