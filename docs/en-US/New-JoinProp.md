---
external help file: PSBusinessPlusERP-help.xml
Module Name: PSBusinessPlusERP
online version:
schema: 2.0.0
---

# New-JoinProp

## SYNOPSIS
Returns New ReportFetch Join Prop String.

## SYNTAX

```
New-JoinProp [-Bt20Name] <String> [-FromId] <String> [-ToId] <String> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Returns New ReportFetch Join Prop String based on the provided parameters.

## EXAMPLES

### EXAMPLE 1
```
New-JoinProp -Bt20Name "BT20.HrEmpPay" -FromId "Id" -ToId "Id"
```

## PARAMETERS

### -Bt20Name
The Bt20 object name to join to.

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

### -FromId
The Bt20 Object column id to join from.

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

### -ToId
The Bt20 Object column id to join to.

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

### String formatted to be utilized in generating a Join in the ReportFetch Module
## NOTES
v0.0.1 -- Birge, Zach -- 2024-05-30 -- Initial Release

## RELATED LINKS
