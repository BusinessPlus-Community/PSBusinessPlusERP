@{
    # Use Severity when you want to limit the generated diagnostic records to a
    # subset of: Error, Warning and Information.
    # Uncomment the following line if you only want Errors and Warnings but
    # not Information diagnostic records.
    # Severity = @('Error','Warning')

    # Use IncludeRules when you want to run only a subset of the default rule set.
    # IncludeRules = @('PSAvoidDefaultValueSwitchParameter',
    #                  'PSMissingModuleManifestField',
    #                  'PSReservedCmdletChar',
    #                  'PSReservedParams',
    #                  'PSShouldProcess',
    #                  'PSUseApprovedVerbs',
    #                  'PSUseDeclaredVarsMoreThanAssigments')

    # Use ExcludeRules when you want to run most of the default set of rules except
    # for a few rules you wish to "exclude".  Note: if a rule is in both IncludeRules
    # and ExcludeRules, the rule will be excluded.
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSUseShouldProcessForStateChangingFunctions'
    )

    # You can use the following entry to supply parameters to rules that take parameters.
    # For instance, the PSAvoidUsingCmdletAliases rule takes a whitelist for aliases you
    # want to allow.
    Rules = @{
        # Do not flag 'cd' alias.
        PSAvoidUsingCmdletAliases = @{
            Whitelist = @('cd')
        }

        # Check if your script uses cmdlets that are compatible with PowerShell Core,
        # version 7.0 and Windows PowerShell 5.1
        PSUseCompatibleCmdlets = @{
            Compatibility = @('core-7.0-windows', 'desktop-5.1.14393.206-windows')
        }
        
        # Check if your script uses commands that are compatible with PowerShell Core
        PSUseCompatibleCommands = @{
            Enable = $true
            TargetProfiles = @(
                'win-8_x64_10.0.14393.0_5.1.14393.2791_x64_4.0.30319.42000_framework',
                'ubuntu_x64_18.04_7.0.0_x64_3.1.2_core'
            )
        }
        
        # Check if your script uses types that are compatible across versions
        PSUseCompatibleTypes = @{
            Enable = $true
            TargetProfiles = @(
                'win-8_x64_10.0.14393.0_5.1.14393.2791_x64_4.0.30319.42000_framework',
                'ubuntu_x64_18.04_7.0.0_x64_3.1.2_core'
            )
        }
    }
}