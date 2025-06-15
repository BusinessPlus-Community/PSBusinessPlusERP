Function Test-BPERPConnection {
    <#
    .SYNOPSIS
        Tests the connection to a BusinessPlus ERP system

    .DESCRIPTION
        The Test-BPERPConnection function verifies connectivity to a BusinessPlus ERP system
        by attempting to reach the login endpoint. This is useful for validating server
        availability before attempting authentication.

    .PARAMETER Uri
        The base URL of the BusinessPlus ERP system (e.g., https://erp.company.com)

    .PARAMETER Timeout
        The timeout in seconds for the connection test. Default is 10 seconds.

    .PARAMETER Detailed
        If specified, returns detailed connection information including response time
        and server headers. Otherwise returns a simple boolean.

    .EXAMPLE
        PS> Test-BPERPConnection -Uri "https://erp.company.com"
        True

        Tests basic connectivity to the BusinessPlus ERP system

    .EXAMPLE
        PS> Test-BPERPConnection -Uri "https://erp.company.com" -Detailed

        Uri          : https://erp.company.com
        IsAvailable  : True
        ResponseTime : 245
        StatusCode   : 200
        Server       : Microsoft-IIS/10.0

        Tests connectivity and returns detailed information

    .EXAMPLE
        PS> if (Test-BPERPConnection -Uri $erpUri) {
        >>     $cred = Get-Credential
        >>     Invoke-BPERPLogin -Credential $cred -Uri $erpUri
        >> }

        Tests connectivity before attempting login

    .OUTPUTS
        System.Boolean or System.Management.Automation.PSCustomObject
        Returns boolean by default, or detailed object with -Detailed parameter
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean], [System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^https?://')]
        [string]$Uri,

        [Parameter()]
        [ValidateRange(1, 300)]
        [int]$Timeout = 10,

        [Parameter()]
        [switch]$Detailed
    )

    begin {
        Write-Verbose "Starting Test-BPERPConnection"

        # Remove trailing slash from URI if present
        $Uri = $Uri.TrimEnd('/')
    }

    process {
        # Validate URI format first
        try {
            $null = [System.Uri]::new($Uri)
        }
        catch {
            if ($Detailed) {
                return [PSCustomObject]@{
                    Uri = $Uri
                    IsAvailable = $false
                    ResponseTime = -1
                    StatusCode = 0
                    Error = "Invalid URI format: $Uri"
                    TestedAt = [DateTime]::UtcNow
                }
            }
            else {
                Write-Warning "Invalid URI format: $Uri"
                return $false
            }
        }

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        try {
            Write-Verbose "Testing connection to: $Uri"

            # Test the login endpoint
            $testUri = "$Uri/BTMQ/api/finance/User/Login"

            $splat = @{
                Uri = $testUri
                Method = 'Head'
                TimeoutSec = $Timeout
                ErrorAction = 'Stop'
                UseBasicParsing = $true
            }

            # For detailed output, use GET to get headers
            if ($Detailed) {
                $splat.Method = 'Get'
            }

            try {
                $response = Invoke-WebRequest @splat
                $stopwatch.Stop()

                Write-Verbose "Connection successful. Response time: $($stopwatch.ElapsedMilliseconds)ms"

                if ($Detailed) {
                    return [PSCustomObject]@{
                        Uri = $Uri
                        IsAvailable = $true
                        ResponseTime = $stopwatch.ElapsedMilliseconds
                        StatusCode = $response.StatusCode
                        Server = $response.Headers['Server'] -join ', '
                        TestedAt = [DateTime]::UtcNow
                    }
                }
                else {
                    return $true
                }
            }
            catch [System.Net.WebException] {
                $stopwatch.Stop()

                # Check if it's a 405 Method Not Allowed (expected for HEAD request)
                if ($_.Exception.Response.StatusCode -eq 'MethodNotAllowed') {
                    Write-Verbose "Server doesn't support HEAD method, but endpoint exists"

                    if ($Detailed) {
                        return [PSCustomObject]@{
                            Uri = $Uri
                            IsAvailable = $true
                            ResponseTime = $stopwatch.ElapsedMilliseconds
                            StatusCode = 405
                            Server = $_.Exception.Response.Headers['Server']
                            TestedAt = [DateTime]::UtcNow
                        }
                    }
                    else {
                        return $true
                    }
                }
                else {
                    throw
                }
            }
        }
        catch {
            $stopwatch.Stop()

            Write-Verbose "Connection failed: $_"

            if ($Detailed) {
                return [PSCustomObject]@{
                    Uri = $Uri
                    IsAvailable = $false
                    ResponseTime = $stopwatch.ElapsedMilliseconds
                    StatusCode = 0
                    Error = $_.Exception.Message
                    TestedAt = [DateTime]::UtcNow
                }
            }
            else {
                Write-Warning "Connection to $Uri failed: $_"
                return $false
            }
        }
    }

    end {
        Write-Verbose "Completed Test-BPERPConnection"
    }
}