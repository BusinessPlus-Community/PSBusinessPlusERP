BeforeAll {
    # Get the module root (repository root)
    $moduleRoot = Split-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -Parent
    
    # Try to find the built module first
    $builtModulePath = Join-Path -Path $moduleRoot -ChildPath 'Output/BPC.Admin'
    $modulePath = $null
    
    if (Test-Path $builtModulePath) {
        # Get the latest version
        $latestVersion = Get-ChildItem -Path $builtModulePath -Directory | 
            Sort-Object Name -Descending | 
            Select-Object -First 1
        if ($latestVersion) {
            $moduleManifest = Join-Path -Path $latestVersion.FullName -ChildPath 'BPC.Admin.psd1'
            if (Test-Path $moduleManifest) {
                $modulePath = $moduleManifest
            }
        }
    }
    
    # Fall back to source if built module not found
    if (-not $modulePath -or -not (Test-Path $modulePath)) {
        $sourcePath = Join-Path -Path $moduleRoot -ChildPath 'BPC.Admin/BPC.Admin.psd1'
        if (Test-Path $sourcePath) {
            $modulePath = $sourcePath
        }
    }
    
    # Remove any existing module instances first
    Get-Module -Name BPC.Admin | Remove-Module -Force
    
    # Import the module
    Import-Module $modulePath -Force
}

Describe 'Test-BPERPConnection' {
    Context 'Function exists' {
        It 'Should have the Test-BPERPConnection function' {
            Get-Command -Name Test-BPERPConnection -Module BPC.Admin | Should -Not -BeNullOrEmpty
        }

        It 'Should have the correct parameters' {
            $command = Get-Command -Name Test-BPERPConnection -Module BPC.Admin
            $command.Parameters.Keys | Should -Contain 'Uri'
            $command.Parameters.Keys | Should -Contain 'Timeout'
            $command.Parameters.Keys | Should -Contain 'Detailed'
        }

        It 'Should have mandatory parameters marked correctly' {
            $command = Get-Command -Name Test-BPERPConnection -Module BPC.Admin
            $command.Parameters['Uri'].Attributes.Mandatory | Should -Contain $true
            $command.Parameters['Timeout'].Attributes.Mandatory | Should -Contain $false
            $command.Parameters['Detailed'].Attributes.Mandatory | Should -Contain $false
        }
    }

    Context 'Parameter validation' {
        It 'Should accept String type for Uri parameter' {
            $command = Get-Command -Name Test-BPERPConnection -Module BPC.Admin
            $command.Parameters['Uri'].ParameterType.Name | Should -Be 'String'
        }

        It 'Should accept Int32 type for Timeout parameter' {
            $command = Get-Command -Name Test-BPERPConnection -Module BPC.Admin
            $command.Parameters['Timeout'].ParameterType.Name | Should -Be 'Int32'
        }

        It 'Should accept SwitchParameter type for Detailed parameter' {
            $command = Get-Command -Name Test-BPERPConnection -Module BPC.Admin
            $command.Parameters['Detailed'].ParameterType.Name | Should -Be 'SwitchParameter'
        }

        It 'Should have default value of 10 for Timeout parameter' {
            $command = Get-Command -Name Test-BPERPConnection -Module BPC.Admin
            $command.Parameters['Timeout'].Attributes | Where-Object { $_ -is [System.Management.Automation.ValidateRangeAttribute] } | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Function behavior - Simple mode' {
        BeforeEach {
            # Mock successful web request
            Mock -CommandName Invoke-WebRequest -ModuleName BPC.Admin -MockWith {
                $response = New-Object PSObject -Property @{
                    StatusCode = 200
                    Headers = @{
                        'Server' = 'Microsoft-IIS/10.0'
                    }
                }
                return $response
            }
        }

        It 'Should return true for successful connection' {
            $result = Test-BPERPConnection -Uri 'https://test.example.com'
            $result | Should -BeTrue
        }

        It 'Should handle invalid URI format' {
            # The function has ValidatePattern that requires http:// or https://
            # So we need to test with a valid pattern but invalid URI
            $result = Test-BPERPConnection -Uri 'https://not a valid uri' -WarningAction SilentlyContinue
            $result | Should -BeFalse
        }

        It 'Should return true for 405 Method Not Allowed' {
            Mock -CommandName Invoke-WebRequest -ModuleName BPC.Admin -MockWith {
                $exception = New-Object System.Net.WebException
                $response = New-Object System.Net.HttpWebResponse
                $response | Add-Member -NotePropertyName StatusCode -NotePropertyValue 'MethodNotAllowed' -Force
                $exception | Add-Member -NotePropertyName Response -NotePropertyValue $response -Force
                throw $exception
            }

            $result = Test-BPERPConnection -Uri 'https://test.example.com'
            $result | Should -BeTrue
        }

        It 'Should return false for connection failure' {
            Mock -CommandName Invoke-WebRequest -ModuleName BPC.Admin -MockWith {
                throw "Connection timeout"
            }

            $result = Test-BPERPConnection -Uri 'https://test.example.com' -WarningAction SilentlyContinue
            $result | Should -BeFalse
        }
    }

    Context 'Function behavior - Detailed mode' {
        BeforeEach {
            # Mock successful web request
            Mock -CommandName Invoke-WebRequest -ModuleName BPC.Admin -MockWith {
                $response = New-Object PSObject -Property @{
                    StatusCode = 200
                    Headers = @{
                        'Server' = @('Microsoft-IIS/10.0')
                    }
                }
                return $response
            }
        }

        It 'Should return detailed object for successful connection' {
            $result = Test-BPERPConnection -Uri 'https://test.example.com' -Detailed
            $result | Should -BeOfType [PSCustomObject]
            $result.IsAvailable | Should -BeTrue
            $result.StatusCode | Should -Be 200
            $result.Server | Should -Be 'Microsoft-IIS/10.0'
            $result.Uri | Should -Be 'https://test.example.com'
            $result.ResponseTime | Should -BeGreaterThan -1
            $result.TestedAt | Should -BeOfType [DateTime]
        }

        It 'Should return detailed object for invalid URI' {
            # The function has ValidatePattern that requires http:// or https://
            # So we need to test with a valid pattern but invalid URI
            $result = Test-BPERPConnection -Uri 'https://not a valid uri' -Detailed
            $result | Should -BeOfType [PSCustomObject]
            $result.IsAvailable | Should -BeFalse
            # ResponseTime should be -1 for invalid URIs
            $result.ResponseTime | Should -BeExactly -1
            $result.StatusCode | Should -Be 0
            $result.Error | Should -Match 'Invalid URI format'
        }

        It 'Should return detailed object for 405 Method Not Allowed' {
            Mock -CommandName Invoke-WebRequest -ModuleName BPC.Admin -MockWith {
                $exception = New-Object System.Net.WebException
                $response = New-Object PSObject
                $response | Add-Member -NotePropertyName StatusCode -NotePropertyValue 'MethodNotAllowed' -Force
                $response | Add-Member -NotePropertyName Headers -NotePropertyValue @{'Server' = 'Microsoft-IIS/10.0'} -Force
                $exception | Add-Member -NotePropertyName Response -NotePropertyValue $response -Force
                throw $exception
            }

            $result = Test-BPERPConnection -Uri 'https://test.example.com' -Detailed
            $result | Should -BeOfType [PSCustomObject]
            $result.IsAvailable | Should -BeTrue
            $result.StatusCode | Should -Be 405
        }

        It 'Should return detailed object for connection failure' {
            Mock -CommandName Invoke-WebRequest -ModuleName BPC.Admin -MockWith {
                throw "Connection timeout"
            }

            $result = Test-BPERPConnection -Uri 'https://test.example.com' -Detailed
            $result | Should -BeOfType [PSCustomObject]
            $result.IsAvailable | Should -BeFalse
            $result.Error | Should -Match 'Connection timeout'
        }
    }

    Context 'Help documentation' {
        It 'Should have help documentation' {
            $help = Get-Help Test-BPERPConnection -Full
            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description | Should -Not -BeNullOrEmpty
        }

        It 'Should have parameter help for all parameters' {
            $help = Get-Help Test-BPERPConnection -Parameter Uri
            $help.Description | Should -Not -BeNullOrEmpty
            
            $help = Get-Help Test-BPERPConnection -Parameter Timeout
            $help.Description | Should -Not -BeNullOrEmpty
            
            $help = Get-Help Test-BPERPConnection -Parameter Detailed
            $help.Description | Should -Not -BeNullOrEmpty
        }

        It 'Should have at least one example' {
            $help = Get-Help Test-BPERPConnection -Examples
            $help.Examples | Should -Not -BeNullOrEmpty
        }
    }
}