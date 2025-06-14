
Function Get-BPERPExample {
    <#
    .SYNOPSIS
        Returns a greeting message
    .DESCRIPTION
        The Get-BPERPExample function returns a greeting message. By default, it greets 'User',
        but you can specify a custom name to personalize the greeting.
    .PARAMETER Name
        The name to include in the greeting. Defaults to 'User'.
    .EXAMPLE
        PS> Get-BPERPExample
        Hello, User!

        Returns the default greeting
    .EXAMPLE
        PS> Get-BPERPExample -Name 'Alice'
        Hello, Alice!

        Returns a personalized greeting
    .EXAMPLE
        PS> 'Bob' | Get-BPERPExample
        Hello, Bob!

        Demonstrates pipeline input
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Enter the name to greet'
        )]
        [ValidateNotNull()]
        [string]$Name = 'User'
    )

    begin {
        Write-Verbose "Starting Get-BPERPExample"
    }

    process {
        try {
            $greeting = "Hello, {0}!" -f $Name
            Write-Verbose "Generated greeting: $greeting"
            return $greeting
        }
        catch {
            Write-Error "An error occurred while generating the greeting: $_"
            throw
        }
    }

    end {
        Write-Verbose "Completed Get-BPERPExample"
    }
}
