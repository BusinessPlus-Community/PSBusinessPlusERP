---
external help file: BPC.Admin-help.xml
Module Name: BPC.Admin
online version:
schema: 2.0.0
---

# Invoke-BPERPLogin

## SYNOPSIS
Short description

## SYNTAX

```
Invoke-BPERPLogin [-Credential] <PSCredential> [-Uri] <String> [-ReturnConnection]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Long description

## EXAMPLES

### EXAMPLE 1
```
An example
```

## PARAMETERS

### -Credential
PSCredential object containing the username and password for authentication

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

### -Uri
The base URL of the BusinessPlus ERP system (e.g., https://erp.company.com)

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

### -ReturnConnection
If specified, returns the full connection object including headers and response.
Otherwise, returns only the authentication response.

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

### System.Management.Automation.PSObject
## NOTES
General notes

## RELATED LINKS
