
Function Get-BPERPExample {
    <#
    .SYNOPSIS
        Returns Hello world
    .DESCRIPTION
        Returns Hello world
    .EXAMPLE
        PS> Get-BPERPExample

        Runs the command
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        # Parameter description can go here or above in format: .PARAMETER  <Parameter-Name>
        [Parameter()]
        [string]$Value = 'GetBPERPExample'
    )

    $Value
}
