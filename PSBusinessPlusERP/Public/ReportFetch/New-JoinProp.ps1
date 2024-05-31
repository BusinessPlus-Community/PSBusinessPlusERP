Function New-JoinProp {
    <#
    .SYNOPSIS
    Returns New ReportFetch Join Prop String.

    .DESCRIPTION
    Returns New ReportFetch Join Prop String based on the provided parameters.

    .PARAMETER Bt20Name
    The Bt20 object name to join to.

    .PARAMETER FromId
    The Bt20 Object column id to join from.

    .PARAMETER ToId
    The Bt20 Object column id to join to.

    .EXAMPLE
    PS> New-JoinProp -Bt20Name "BT20.HrEmpPay" -FromId "Id" -ToId "Id"

    .OUTPUTS
    String formatted to be utilized in generating a Join in the ReportFetch Module

    .NOTES
    v0.0.1 -- Birge, Zach -- 2024-05-30 -- Initial Release
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Bt20Name,

        [Parameter(Mandatory)]
        [string]
        $FromId,

        [Parameter(Mandatory)]
        [string]
        $ToId
    )

    Return "<JoinProp BT20OBJ=`"$Bt20Name`" From=`"$FromId`" To=`"$ToId`""
}
