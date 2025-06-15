# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the BPC.Admin module - a PowerShell module providing administrative cmdlets for BusinessPlus ERP/HR/PY systems. This module is part of the BPC (BusinessPlus Community) namespace.

## Module Namespace

The BusinessPlus Community uses the BPC namespace for all modules:
- `BPC.Admin` - Administrative functions (this module)
- `BPC.DBRefresh` - Database refresh operations
- `BPC.Reports` - Report generation/fetching
- `BPC.Security` - User/permission management
- `BPC.Finance` - Financial operations
- `BPC.HR` - Human resources functions

## Module Dependencies

This module requires:
- PowerShell 5.1 or higher
- dbatools 2.1.1+ (for SQL Server operations)
- SQL Server 2016 or newer (for database functions)

## Development Standards

All functions use the BPERP prefix:
- `Invoke-BPERPLogin`
- `Get-BPERPExample`
- `New-BPERPJoinProperty`

## Migration Status

This module has been successfully migrated from `PSBusinessPlusERP` to `BPC.Admin`. The following changes have been completed:

### Renamed Files
- `PSBusinessPlusERP.psd1` → `BPC.Admin.psd1`
- `PSBusinessPlusERP.psm1` → `BPC.Admin.psm1`
- `about_PSBusinessPlusERP.help.md` → `about_BPC.Admin.help.md`
- `Invoke-BusinessPlusLogin.ps1` → `Invoke-BPERPLogin.ps1`
- `Get-HelloWorld.ps1` → `Get-BPERPExample.ps1`

### Other Changes
- Removed old `Output/PSBusinessPlusERP/` directory containing legacy builds
- Module manifest contains complete metadata (ProjectUri, LicenseUri, Tags)
- All function names follow the BPERP prefix convention
- Module exports are explicitly defined (no wildcards)
- PowerShell version requirement set to 5.1+

### Repository Status
- Repository has been renamed from `PSBusinessPlusERP` to `BPC.Admin` on GitHub
- Current version: 0.2.0
- Full CI/CD pipeline implemented with GitHub Actions
- Multi-platform testing (Windows, Linux, macOS)
- Automated PowerShell Gallery publishing on release

### Related Modules
The companion `BPC.DBRefresh` module has been fully migrated to the BPC namespace and updated to follow the same patterns as BPC.Admin. Both modules now share consistent:
- Build systems (PSake with PowerShellBuild)
- Test frameworks (Pester 5.7.1)
- Code analysis settings (PSScriptAnalyzer with compatibility rules)
- VS Code configurations (4-space indentation)
- Documentation standards

## Build System

This module uses PSake for build automation with the following key commands:
- `./build.ps1` - Run the full build pipeline including tests and analysis
- `./build.ps1 -Bootstrap` - Install build dependencies first
- `./build.ps1 -Task Test` - Run tests only
- Build outputs are generated in `Output/BPC.Admin/{version}/`
- Tests are located in the `tests/` directory using Pester 5.7.1

### Build Dependencies
- PowerShellBuild 0.6.1
- Pester 5.7.1 (with SkipPublisherCheck for certificate issues)
- PSScriptAnalyzer 1.19.1
- BuildHelpers 2.0.16
- psake 4.9.0

## Current Functions

### Exported Functions

#### Web API Functions
- `Invoke-BPERPLogin` - Authenticates users to BusinessPlus ERP system with enhanced security
- `Test-BPERPConnection` - Tests connectivity to BusinessPlus ERP web services

#### Database Functions (via dbatools)
- `Test-BPERPDatabaseConnection` - Tests connectivity to BusinessPlus SQL Server databases (SQL Server 2016+)
- `Invoke-BPERPQuery` - Executes parameterized queries against BusinessPlus databases with multiple output formats

### Classes
The module includes a sophisticated ReportFetch class system in `BPC.Admin/Classes/ReportFetch/` for building XML requests. Classes include:
- `ReportFetch` - Main class for building report fetch requests
- `ReportFetchDataObject` - Represents data objects in requests
- `ReportFetchProperty` - Represents properties to fetch
- `ReportFetchWhereClause` - Build WHERE conditions
- `ReportFetchWhereGroup` - Group WHERE clauses
- `ReportFetchWhereParam` - Individual WHERE parameters
- `ReportFetchJoinClause` - Build JOIN conditions
- `ReportFetchJoinParam` - Individual JOIN parameters
- `ReportFetchOrderByClause` - Build ORDER BY conditions
- `ReportFetchOrderByParam` - Individual ORDER BY parameters

## Test Suite

The module has comprehensive test coverage (95+ tests passing):
- Module manifest validation tests
- Git tagging tests (skipped on non-release branches)
- Text file formatting tests (Meta.tests.ps1)
- Complete ReportFetch class tests (75+ tests)
- Help documentation tests (Help.tests.ps1)
- Public function unit tests with mocking
- Parameter validation tests
- Code coverage reporting configured (80% target)

### Test Organization
```
tests/
├── Public/                  # Function-specific tests
│   ├── Get-BPERPExample.Tests.ps1
│   └── User/
│       └── Invoke-BPERPLogin.Tests.ps1
├── Help.tests.ps1          # Documentation validation
├── Manifest.tests.ps1      # Module manifest tests
├── Meta.tests.ps1          # Code quality tests
└── ReportFetch.Tests.ps1   # Class tests
```

### Known Test Considerations
- PowerShell classes don't support constructor overloading, so all parameters must be provided
- XML generated by the classes uses single quotes, but XmlDocument normalizes to double quotes
- Export-ModuleMember cannot be used in class files that are dot-sourced for testing
- ProgressAction parameter help is auto-generated and may fail help tests

## VS Code Configuration

The repository includes comprehensive VS Code settings:
- PowerShell formatting using OTBS style with 4-space indentation
- Cross-platform terminal profiles for PowerShell 7
- Optimized extension recommendations (minimal set for performance)
- File exclusions for build artifacts and local directories
- PSScriptAnalyzer integration with custom rules
- Auto-formatting on save, paste, and type
- Consistent whitespace handling

## Security and Documentation

- `SECURITY.md` - Complete security policy with vulnerability reporting procedures
- `NOTICE.md` - Third-party software notices and acknowledgments
- `LICENSE` - GPL-3.0 license

## Directory Structure

```
BPC.Admin/
├── .github/
│   └── workflows/          # GitHub Actions CI/CD pipelines
├── BPC.Admin/              # Module source
│   ├── Classes/            # PowerShell classes
│   ├── Private/            # Internal functions
│   └── Public/             # Exported functions
├── docs/                   # Module documentation
├── tests/                  # Pester tests
│   └── Public/             # Function-specific tests
├── .vscode/                # VS Code workspace settings
├── build.ps1               # Build script
├── psakeFile.ps1          # Build task definitions
├── requirements.psd1       # Build dependencies
└── PSScriptAnalyzerSettings.psd1  # Code analysis rules
```

## Ignored Directories

The following directories are ignored by git and should not be committed:
- `/Output/` - Build artifacts
- `/scratch/` - Temporary files
- `/.claude/` - Claude-specific files
- `/context/` - Context documentation

## CI/CD Pipeline

The module includes comprehensive GitHub Actions workflows:

### CI Workflow (`ci.yml`)
- Runs on push to main/v2 branches and pull requests
- Tests on multiple platforms (Windows, Linux, macOS)
- Executes PSScriptAnalyzer for code quality
- Runs full test suite with Pester
- Generates code coverage reports (Linux only)
- Uploads test results as artifacts

### Release Workflow (`release.yml`)
- Triggers on version tags (v*)
- Runs full test suite before release
- Builds and packages the module
- Creates GitHub releases with artifacts
- Publishes to PowerShell Gallery (requires PSGALLERY_API_KEY secret)

## Code Quality Standards

### PSScriptAnalyzer Configuration
- Compatibility rules enabled for PowerShell 5.1 and 7.0+
- Cross-platform compatibility checking
- Minimal rule exclusions (only PSAvoidUsingWriteHost and PSUseShouldProcessForStateChangingFunctions)
- Consistent code formatting enforced

### Function Standards
- All public functions include:
  - Comprehensive help documentation with examples
  - Parameter validation
  - Error handling with try-catch blocks
  - Verbose logging
  - Pipeline support where appropriate
- Functions are tested with unit tests including mocking

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.