@{
    # Use default rules
    IncludeDefaultRules = $true
    
    # Exclude specific rules if needed
    ExcludeRules = @(
        # PSUseShouldProcessForStateChangingFunctions - Not all state-changing functions need ShouldProcess
        'PSUseShouldProcessForStateChangingFunctions',
        
        # PSAvoidUsingWriteHost - Sometimes needed for interactive scripts
        'PSAvoidUsingWriteHost'
    )
    
    # Include specific rules
    Rules = @{
        # Ensure compatibility with PowerShell Core
        PSUseCompatibleSyntax = @{
            Enable = $true
            TargetVersions = @(
                '5.1',
                '7.0'
            )
        }
        
        # Ensure compatible commands
        PSUseCompatibleCommands = @{
            Enable = $true
            TargetProfiles = @(
                'win-8_x64_10.0.14393.0_5.1.14393.2791_x64_4.0.30319.42000_framework',  # Server 2016
                'win-8_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework',   # Server 2019
                'win-48_x64_10.0.17763.0_5.1.17763.316_x64_4.0.30319.42000_framework'   # Windows 10
            )
        }
    }
    
    # Severity levels to include
    Severity = @(
        'Error',
        'Warning',
        'Information'
    )
}