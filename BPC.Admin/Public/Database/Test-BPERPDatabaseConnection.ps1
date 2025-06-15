Function Test-BPERPDatabaseConnection {
    <#
    .SYNOPSIS
        Tests the connection to a BusinessPlus ERP SQL Server database

    .DESCRIPTION
        The Test-BPERPDatabaseConnection function verifies connectivity to a BusinessPlus ERP
        SQL Server database using dbatools. This function supports SQL Server 2016 and newer,
        and can test both Windows Authentication and SQL Authentication.

    .PARAMETER SqlInstance
        The SQL Server instance to connect to. Can be a server name, server\instance,
        or a SQL Server connection object.

    .PARAMETER Database
        The database name to test connectivity against. If not specified, tests
        connection to the SQL Server instance only.

    .PARAMETER SqlCredential
        SQL Server credential object for SQL Authentication. If not provided,
        Windows Authentication will be used.

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Test-BPERPDatabaseConnection -SqlInstance "SQLSERVER01"

        Tests connectivity to SQLSERVER01 using Windows Authentication

    .EXAMPLE
        PS> Test-BPERPDatabaseConnection -SqlInstance "SQLSERVER01\BPERP" -Database "BusinessPlusERP"

        Tests connectivity to the BusinessPlusERP database on SQLSERVER01\BPERP instance

    .EXAMPLE
        PS> $cred = Get-Credential
        PS> Test-BPERPDatabaseConnection -SqlInstance "SQLSERVER01" -SqlCredential $cred -Database "BusinessPlusERP"

        Tests connectivity using SQL Authentication

    .EXAMPLE
        PS> $servers = "SQL01", "SQL02", "SQL03"
        PS> $servers | Test-BPERPDatabaseConnection -Database "BusinessPlusERP"

        Tests connectivity to multiple servers via pipeline

    .OUTPUTS
        System.Management.Automation.PSCustomObject
        Returns connection test results including server version and database status
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [DbaInstanceParameter[]]$SqlInstance,

        [Parameter(Position = 1)]
        [string]$Database,

        [Parameter()]
        [PSCredential]$SqlCredential,

        [Parameter()]
        [switch]$EnableException
    )

    begin {
        Write-Verbose "Starting Test-BPERPDatabaseConnection"

        # Ensure dbatools module is available
        if (-not (Get-Module -Name dbatools -ListAvailable)) {
            $message = "The dbatools module is required but not installed. Please install it using: Install-Module dbatools"
            if ($EnableException) {
                throw $message
            }
            else {
                Write-Warning $message
                return
            }
        }

        # Import dbatools if not already loaded
        if (-not (Get-Module -Name dbatools)) {
            try {
                Import-Module dbatools -ErrorAction Stop
                Write-Verbose "Successfully imported dbatools module"
            }
            catch {
                $message = "Failed to import dbatools module: $_"
                if ($EnableException) {
                    throw $message
                }
                else {
                    Write-Warning $message
                    return
                }
            }
        }
    }

    process {
        foreach ($instance in $SqlInstance) {
            Write-Verbose "Testing connection to: $instance"

            try {
                # Test basic connectivity first
                $testParams = @{
                    SqlInstance = $instance
                    EnableException = $true
                }

                if ($PSBoundParameters.ContainsKey('SqlCredential')) {
                    $testParams['SqlCredential'] = $SqlCredential
                }

                $connectTest = Test-DbaConnection @testParams

                if (-not $connectTest.ConnectSuccess) {
                    $result = [PSCustomObject]@{
                        ComputerName = $connectTest.ComputerName
                        InstanceName = $connectTest.InstanceName
                        SqlInstance = $connectTest.SqlInstance
                        IsConnected = $false
                        DatabaseExists = $false
                        DatabaseOnline = $false
                        Error = "Failed to connect to SQL instance"
                        SqlVersion = $null
                        SqlEdition = $null
                        AuthType = if ($SqlCredential) { "SQL" } else { "Windows" }
                    }

                    if ($EnableException) {
                        throw "Failed to connect to $instance"
                    }
                    else {
                        Write-Warning "Failed to connect to $instance"
                        $result
                    }
                    continue
                }

                # Get server information
                $serverInfo = Get-DbaServer @testParams

                $result = [PSCustomObject]@{
                    ComputerName = $connectTest.ComputerName
                    InstanceName = $connectTest.InstanceName
                    SqlInstance = $connectTest.SqlInstance
                    IsConnected = $true
                    DatabaseExists = $null
                    DatabaseOnline = $null
                    SqlVersion = $serverInfo.Version
                    SqlEdition = $serverInfo.Edition
                    AuthType = if ($SqlCredential) { "SQL" } else { "Windows" }
                    Error = $null
                }

                # If database specified, test database connectivity
                if ($Database) {
                    Write-Verbose "Testing database: $Database"

                    try {
                        $dbParams = @{
                            SqlInstance = $instance
                            Database = $Database
                            EnableException = $true
                        }

                        if ($PSBoundParameters.ContainsKey('SqlCredential')) {
                            $dbParams['SqlCredential'] = $SqlCredential
                        }

                        $dbInfo = Get-DbaDatabase @dbParams

                        if ($dbInfo) {
                            $result.DatabaseExists = $true
                            $result.DatabaseOnline = $dbInfo.Status -eq 'Normal'

                            if ($dbInfo.Status -ne 'Normal') {
                                $result.Error = "Database exists but status is: $($dbInfo.Status)"
                            }
                        }
                        else {
                            $result.DatabaseExists = $false
                            $result.DatabaseOnline = $false
                            $result.Error = "Database '$Database' not found"
                        }
                    }
                    catch {
                        $result.DatabaseExists = $false
                        $result.DatabaseOnline = $false
                        $result.Error = "Error accessing database: $_"

                        if ($EnableException) {
                            throw $_
                        }
                        else {
                            Write-Warning "Error accessing database '$Database' on $instance : $_"
                        }
                    }
                }

                # Output result
                $result
            }
            catch {
                $errorResult = [PSCustomObject]@{
                    ComputerName = $instance.ComputerName
                    InstanceName = $instance.InstanceName
                    SqlInstance = $instance
                    IsConnected = $false
                    DatabaseExists = $false
                    DatabaseOnline = $false
                    SqlVersion = $null
                    SqlEdition = $null
                    AuthType = if ($SqlCredential) { "SQL" } else { "Windows" }
                    Error = $_.Exception.Message
                }

                if ($EnableException) {
                    throw $_
                }
                else {
                    Write-Warning "Error testing connection to $instance : $_"
                    $errorResult
                }
            }
        }
    }

    end {
        Write-Verbose "Completed Test-BPERPDatabaseConnection"
    }
}