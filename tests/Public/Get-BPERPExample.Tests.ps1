BeforeAll {
    $moduleRoot = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $modulePath = Join-Path -Path $moduleRoot -ChildPath 'BPC.Admin'
    
    # Remove any existing module instances first
    Get-Module -Name BPC.Admin | Remove-Module -Force
    
    # Import the module
    Import-Module $modulePath -Force
}

Describe 'Get-BPERPExample' {
    Context 'Function exists' {
        It 'Should have the Get-BPERPExample function' {
            Get-Command -Name Get-BPERPExample -Module BPC.Admin | Should -Not -BeNullOrEmpty
        }

        It 'Should have the correct parameters' {
            $command = Get-Command -Name Get-BPERPExample -Module BPC.Admin
            $command.Parameters.Keys | Should -Contain 'Name'
        }
    }

    Context 'Function behavior' {
        It 'Should return a string with default parameter' {
            $result = Get-BPERPExample
            $result | Should -BeOfType [string]
            $result | Should -Be 'Hello, User!'
        }

        It 'Should return a string with custom name' {
            $result = Get-BPERPExample -Name 'TestUser'
            $result | Should -BeOfType [string]
            $result | Should -Be 'Hello, TestUser!'
        }

        It 'Should accept pipeline input' {
            $result = 'PipelineUser' | Get-BPERPExample
            $result | Should -Be 'Hello, PipelineUser!'
        }

        It 'Should handle empty string input' {
            $result = Get-BPERPExample -Name ''
            $result | Should -Be 'Hello, !'
        }

        It 'Should handle special characters in name' {
            $result = Get-BPERPExample -Name 'Test@User#123'
            $result | Should -Be 'Hello, Test@User#123!'
        }
    }

    Context 'Help documentation' {
        It 'Should have help documentation' {
            $help = Get-Help Get-BPERPExample -Full
            $help.Synopsis | Should -Not -BeNullOrEmpty
            $help.Description | Should -Not -BeNullOrEmpty
            $help.Examples | Should -Not -BeNullOrEmpty
        }

        It 'Should have parameter help' {
            $help = Get-Help Get-BPERPExample -Parameter Name
            $help.Description | Should -Not -BeNullOrEmpty
        }
    }
}