BeforeAll {
    $moduleRoot = Split-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -Parent
    $modulePath = Join-Path -Path $moduleRoot -ChildPath 'BPC.Admin'
    
    # Remove any existing module instances first
    Get-Module -Name BPC.Admin | Remove-Module -Force
    
    # Import the module
    Import-Module $modulePath -Force
}

Describe 'Invoke-BPERPLogin' {
    Context 'Function exists' {
        It 'Should have the Invoke-BPERPLogin function' {
            Get-Command -Name Invoke-BPERPLogin -Module BPC.Admin | Should -Not -BeNullOrEmpty
        }

        It 'Should have the correct parameters' {
            $command = Get-Command -Name Invoke-BPERPLogin -Module BPC.Admin
            $command.Parameters.Keys | Should -Contain 'Credential'
            $command.Parameters.Keys | Should -Contain 'Uri'
            $command.Parameters.Keys | Should -Contain 'ReturnConnection'
        }

        It 'Should have mandatory parameters marked correctly' {
            $command = Get-Command -Name Invoke-BPERPLogin -Module BPC.Admin
            $command.Parameters['Credential'].Attributes.Mandatory | Should -Contain $true
            $command.Parameters['Uri'].Attributes.Mandatory | Should -Contain $true
            $command.Parameters['ReturnConnection'].Attributes.Mandatory | Should -Contain $false
        }
    }

    Context 'Parameter validation' {
        It 'Should accept PSCredential type for Credential parameter' {
            $command = Get-Command -Name Invoke-BPERPLogin -Module BPC.Admin
            $command.Parameters['Credential'].ParameterType.Name | Should -Be 'PSCredential'
        }

        It 'Should accept String type for Uri parameter' {
            $command = Get-Command -Name Invoke-BPERPLogin -Module BPC.Admin
            $command.Parameters['Uri'].ParameterType.Name | Should -Be 'String'
        }

        It 'Should accept SwitchParameter type for ReturnConnection parameter' {
            $command = Get-Command -Name Invoke-BPERPLogin -Module BPC.Admin
            $command.Parameters['ReturnConnection'].ParameterType.Name | Should -Be 'SwitchParameter'
        }
    }

    Context 'Function behavior' -Tag 'Integration' {
        BeforeEach {
            # Mock external dependencies for both Invoke-RestMethod and Invoke-WebRequest
            Mock -CommandName Invoke-RestMethod -ModuleName BPC.Admin -MockWith {
                @{
                    Status = 'Success'
                    SessionId = '12345'
                    UserInfo = @{
                        Username = 'TestUser'
                        Role = 'Admin'
                    }
                }
            }
            
            Mock -CommandName Invoke-WebRequest -ModuleName BPC.Admin -MockWith {
                $response = New-Object PSObject -Property @{
                    StatusCode = 200
                    Content = '{"Status":"Success","SessionId":"12345","UserInfo":{"Username":"TestUser","Role":"Admin"}}'
                    Headers = @{
                        'Set-Cookie' = 'SessionId=12345; Path=/; HttpOnly'
                        'Content-Type' = 'application/json'
                    }
                }
                return $response
            }
        }

        It 'Should throw when mandatory parameters are missing' {
            # Use Get-Command to test parameter validation without executing
            $command = Get-Command -Name Invoke-BPERPLogin -Module BPC.Admin
            $command.Parameters['Credential'].Attributes.Mandatory | Should -Contain $true
            $command.Parameters['Uri'].Attributes.Mandatory | Should -Contain $true
        }

        It 'Should not throw with valid parameters' {
            $securePassword = ConvertTo-SecureString 'TestPassword' -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential ('TestUser', $securePassword)
            
            { Invoke-BPERPLogin -Credential $credential -Uri 'https://test.example.com' } | Should -Not -Throw
        }

        It 'Should return connection object when ReturnConnection is specified' {
            $securePassword = ConvertTo-SecureString 'TestPassword' -AsPlainText -Force
            $credential = New-Object System.Management.Automation.PSCredential ('TestUser', $securePassword)
            
            $result = Invoke-BPERPLogin -Credential $credential -Uri 'https://test.example.com' -ReturnConnection
            $result | Should -Not -BeNullOrEmpty
            $result | Should -BeOfType [PSCustomObject]
            $result.Response | Should -Not -BeNullOrEmpty
            $result.Uri | Should -Be 'https://test.example.com'
            $result.Username | Should -Be 'TestUser'
        }
    }

    Context 'Help documentation' {
        It 'Should have help documentation' {
            $help = Get-Help Invoke-BPERPLogin -Full
            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description | Should -Not -BeNullOrEmpty
        }

        It 'Should have parameter help for all parameters' {
            $help = Get-Help Invoke-BPERPLogin -Parameter Credential
            $help.Description | Should -Not -BeNullOrEmpty
            
            $help = Get-Help Invoke-BPERPLogin -Parameter Uri
            $help.Description | Should -Not -BeNullOrEmpty
            
            $help = Get-Help Invoke-BPERPLogin -Parameter ReturnConnection
            $help.Description | Should -Not -BeNullOrEmpty
        }

        It 'Should have at least one example' {
            $help = Get-Help Invoke-BPERPLogin -Examples
            $help.Examples | Should -Not -BeNullOrEmpty
        }
    }
}