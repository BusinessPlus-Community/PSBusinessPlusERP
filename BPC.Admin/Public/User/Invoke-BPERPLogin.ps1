Function Invoke-BPERPLogin {
    <#
    .SYNOPSIS
        Authenticates a user to the BusinessPlus ERP system

    .DESCRIPTION
        The Invoke-BPERPLogin function authenticates a user to the BusinessPlus ERP system
        using the provided credentials. It returns a connection object containing the
        response headers and authentication details.

    .PARAMETER Credential
        PSCredential object containing the username and password for authentication

    .PARAMETER Uri
        The base URL of the BusinessPlus ERP system (e.g., https://erp.company.com)

    .PARAMETER ReturnConnection
        If specified, returns the full connection object including headers and response.
        Otherwise, returns only the authentication response.

    .EXAMPLE
        PS> $cred = Get-Credential
        PS> Invoke-BPERPLogin -Credential $cred -Uri "https://erp.company.com"

        Authenticates to the BusinessPlus ERP system and returns the response

    .EXAMPLE
        PS> $cred = Get-Credential
        PS> $conn = Invoke-BPERPLogin -Credential $cred -Uri "https://erp.company.com" -ReturnConnection
        PS> $conn.ResponseHeaders

        Authenticates and returns the full connection object with headers

    .OUTPUTS
        System.Object
        Returns authentication response or full connection object based on parameters
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^https?://')]
        [string]$Uri,

        [Parameter()]
        [switch]$ReturnConnection
    )

    begin {
        Write-Verbose "Starting Invoke-BPERPLogin"

        # Remove trailing slash from URI if present
        $Uri = $Uri.TrimEnd('/')

        # Validate URI format
        try {
            $null = [System.Uri]::new($Uri)
        }
        catch {
            throw "Invalid URI format: $Uri"
        }
    }

    process {
        try {
            Write-Verbose "Authenticating user: $($Credential.UserName)"

            $headers = @{
                'Content-Type' = 'application/json; charset=utf-8'
                'Accept' = 'application/json'
            }

            $payload = @{
                user = $Credential.UserName
                pass = $Credential.GetNetworkCredential().Password
            }

            $loginUri = "$Uri/BTMQ/api/finance/User/Login"
            Write-Verbose "Login URI: $loginUri"

            $splat = @{
                Uri = $loginUri
                Method = 'Post'
                Headers = $headers
                Body = (ConvertTo-Json $payload -Compress)
                ErrorAction = 'Stop'
            }

            # PowerShell 7+ supports ResponseHeadersVariable
            if ($PSVersionTable.PSVersion.Major -ge 7) {
                $response = Invoke-RestMethod @splat -ResponseHeadersVariable responseHeaders
            }
            else {
                # For older PowerShell versions, use WebRequest to get headers
                $webResponse = Invoke-WebRequest @splat
                $response = $webResponse.Content | ConvertFrom-Json
                $responseHeaders = $webResponse.Headers
            }

            Write-Verbose "Authentication successful"

            if ($ReturnConnection) {
                return [PSCustomObject]@{
                    ResponseHeaders = $responseHeaders
                    Response = $response
                    Uri = $Uri
                    Username = $Credential.UserName
                    AuthenticatedAt = [DateTime]::UtcNow
                }
            }
            else {
                return $response
            }
        }
        catch {
            Write-Error "Failed to authenticate to BusinessPlus ERP: $_"
            throw
        }
    }

    end {
        Write-Verbose "Completed Invoke-BPERPLogin"
    }
}
