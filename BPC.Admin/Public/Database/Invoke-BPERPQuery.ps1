Function Invoke-BPERPQuery {
    <#
    .SYNOPSIS
        Executes a query against a BusinessPlus ERP SQL Server database

    .DESCRIPTION
        The Invoke-BPERPQuery function executes T-SQL queries against BusinessPlus ERP
        databases using dbatools. It supports parameterized queries, transactions,
        and returns results as PowerShell objects. This function requires SQL Server 2016+.

    .PARAMETER SqlInstance
        The SQL Server instance to connect to. Can be a server name, server\instance,
        or a SQL Server connection object.

    .PARAMETER Database
        The database name to execute the query against.

    .PARAMETER Query
        The T-SQL query to execute. Supports parameterized queries using @ParameterName syntax.

    .PARAMETER SqlParameter
        Hashtable of parameters for parameterized queries. Keys should match parameter
        names in the query (without the @ symbol).

    .PARAMETER CommandType
        The type of command to execute. Options are Text (default) or StoredProcedure.

    .PARAMETER CommandTimeout
        The command timeout in seconds. Default is 30 seconds.

    .PARAMETER SqlCredential
        SQL Server credential object for SQL Authentication. If not provided,
        Windows Authentication will be used.

    .PARAMETER As
        Specifies output format. Options: DataSet, DataTable, DataRow, PSObject (default), SingleValue

    .PARAMETER EnableException
        By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
        This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
        Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .EXAMPLE
        PS> Invoke-BPERPQuery -SqlInstance "SQLSERVER01" -Database "BusinessPlusERP" -Query "SELECT TOP 10 * FROM Users"

        Executes a simple SELECT query and returns results as PSObjects

    .EXAMPLE
        PS> $params = @{
        >>     UserId = 12345
        >>     Active = 1
        >> }
        PS> $query = "SELECT * FROM Users WHERE UserId = @UserId AND Active = @Active"
        PS> Invoke-BPERPQuery -SqlInstance "SQLSERVER01" -Database "BusinessPlusERP" -Query $query -SqlParameter $params

        Executes a parameterized query to prevent SQL injection

    .EXAMPLE
        PS> $result = Invoke-BPERPQuery -SqlInstance "SQLSERVER01" -Database "BusinessPlusERP" -Query "sp_GetUserDetails" -CommandType StoredProcedure -SqlParameter @{UserId = 12345}

        Executes a stored procedure with parameters

    .EXAMPLE
        PS> $count = Invoke-BPERPQuery -SqlInstance "SQLSERVER01" -Database "BusinessPlusERP" -Query "SELECT COUNT(*) FROM Users" -As SingleValue

        Returns a single scalar value

    .OUTPUTS
        System.Management.Automation.PSCustomObject
        Returns query results in the specified format
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param (
        [Parameter(Mandatory, Position = 0)]
        [DbaInstanceParameter]$SqlInstance,

        [Parameter(Mandatory, Position = 1)]
        [string]$Database,

        [Parameter(Mandatory, Position = 2)]
        [string]$Query,

        [Parameter()]
        [hashtable]$SqlParameter,

        [Parameter()]
        [ValidateSet('Text', 'StoredProcedure')]
        [string]$CommandType = 'Text',

        [Parameter()]
        [int]$CommandTimeout = 30,

        [Parameter()]
        [PSCredential]$SqlCredential,

        [Parameter()]
        [ValidateSet('DataSet', 'DataTable', 'DataRow', 'PSObject', 'SingleValue')]
        [string]$As = 'PSObject',

        [Parameter()]
        [switch]$EnableException
    )

    begin {
        Write-Verbose "Starting Invoke-BPERPQuery"

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
        try {
            Write-Verbose "Executing query on $SqlInstance.$Database"

            # Build parameters for Invoke-DbaQuery
            $queryParams = @{
                SqlInstance = $SqlInstance
                Database = $Database
                Query = $Query
                CommandTimeout = $CommandTimeout
                As = $As
                EnableException = $true
            }

            # Add optional parameters
            if ($PSBoundParameters.ContainsKey('SqlCredential')) {
                $queryParams['SqlCredential'] = $SqlCredential
            }

            if ($PSBoundParameters.ContainsKey('SqlParameter') -and $SqlParameter.Count -gt 0) {
                $queryParams['SqlParameter'] = $SqlParameter
            }

            if ($CommandType -eq 'StoredProcedure') {
                $queryParams['CommandType'] = 'StoredProcedure'
            }

            # Log query details in verbose mode
            Write-Verbose "Query Type: $CommandType"
            Write-Verbose "Command Timeout: $CommandTimeout seconds"
            if ($SqlParameter) {
                Write-Verbose "Parameters: $($SqlParameter.Keys -join ', ')"
            }

            # Execute the query
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $results = Invoke-DbaQuery @queryParams
            $stopwatch.Stop()

            Write-Verbose "Query executed successfully in $($stopwatch.ElapsedMilliseconds)ms"

            # Return results
            $results
        }
        catch {
            $message = "Failed to execute query on $SqlInstance.$Database : $_"

            if ($EnableException) {
                throw $_
            }
            else {
                Write-Warning $message
                return
            }
        }
    }

    end {
        Write-Verbose "Completed Invoke-BPERPQuery"
    }
}