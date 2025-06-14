Function Invoke-BPERPLogin {
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param (
        [Parameter(Mandatory)]
        [string]
        [ValidateNotNullOrEmpty()]
        $BusinessPlusUrl,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $UserCredential
    )



    $headers = @{
        'Content-Type' = 'application/json; charset=utf-8'
    }

    $Payload = @{
        user = $UserCredential.UserName
        pass = $UserCredential.GetNetworkCredential().Password
    }

    $Response = Invoke-RestMethod -Uri "$BusinessPlusUrl/BTMQ/api/finance/User/Login" -Method Post -Headers $headers -Body (ConvertTo-Json $Payload)  -ResponseHeadersVariable ResponseHeaders

    return , [PSCustomObject]@{
        ResponseHeaders = $ResponseHeaders
        Response        = $Response
    }

    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER UserName
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>
}
