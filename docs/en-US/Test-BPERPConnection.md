---
external help file: BPC.Admin-help.xml
Module Name: BPC.Admin
online version:
schema: 2.0.0
---

# Test-BPERPConnection

## SYNOPSIS
Tests the connection to a BusinessPlus ERP system

## SYNTAX

```
Test-BPERPConnection [-Uri] <String> [-Timeout <Int32>] [-Detailed] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
The Test-BPERPConnection function verifies connectivity to a BusinessPlus ERP system
by attempting to reach the login endpoint.
This is useful for validating server
availability before attempting authentication.

## EXAMPLES

### EXAMPLE 1
```
Test-BPERPConnection -Uri "https://erp.company.com"
True
```

Tests basic connectivity to the BusinessPlus ERP system

### EXAMPLE 2
```
Test-BPERPConnection -Uri "https://erp.company.com" -Detailed
```

Uri          : https://erp.company.com
IsAvailable  : True
ResponseTime : 245
StatusCode   : 200
Server       : Microsoft-IIS/10.0

Tests connectivity and returns detailed information

### EXAMPLE 3
```
if (Test-BPERPConnection -Uri $erpUri) {
>>     $cred = Get-Credential
>>     Invoke-BPERPLogin -Credential $cred -Uri $erpUri
>> }
```

Tests connectivity before attempting login

## PARAMETERS

### -Uri
The base URL of the BusinessPlus ERP system (e.g., https://erp.company.com)

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

### -Timeout
The timeout in seconds for the connection test.
Default is 10 seconds.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 10
Accept pipeline input: False
Accept wildcard characters: False
```

### -Detailed
If specified, returns detailed connection information including response time
and server headers.
Otherwise returns a simple boolean.

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

### System.Boolean or System.Management.Automation.PSCustomObject
### Returns boolean by default, or detailed object with -Detailed parameter
## NOTES

## RELATED LINKS
