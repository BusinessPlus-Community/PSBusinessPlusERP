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
- `Invoke-BusinessPlusLogin.md` → `Invoke-BPERPLogin.md`
- `New-JoinProp.md` → `New-BPERPJoinProperty.md`

### Other Changes
- Removed old `Output/PSBusinessPlusERP/` directory containing legacy builds
- Module manifest already contains correct BPC.Admin references and metadata
- All function names follow the BPERP prefix convention

### Repository Status
- Repository has been renamed from `PSBusinessPlusERP` to `BPC.Admin` on GitHub
- Current version: 0.2.0 (tagged as v0.2.0)

### Related Modules
The companion `BPC.DBRefresh` module has also been fully migrated to the BPC namespace. References to the old `PSBusinessPlusERP` name exist only in migration documentation and scripts designed to help users transition.

## Build System

This module uses PSake for build automation with the following key commands:
- `./build.ps1` - Run the full build pipeline including tests and analysis
- Build outputs are generated in `Output/BPC.Admin/{version}/`
- Tests are located in the `tests/` directory using Pester 5.x

## Current Functions

### Exported Functions
- `Get-BPERPExample` - Example/template function
- `Invoke-BPERPLogin` - Authenticates users to BusinessPlus ERP system

### Classes
The module includes a sophisticated ReportFetch class system in `BPC.Admin/Classes/ReportFetch/` for building XML requests.

## Known Issues
- `New-BPERPJoinProperty` is documented but not yet implemented
- Some ReportFetch test expectations need updating to match actual class constructors
