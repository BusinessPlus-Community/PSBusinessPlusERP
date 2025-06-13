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
EOF

# 10. Stage all changes
git add -A

# 11. Show status
git status

# 12. Commit (uncomment to run)
# git commit -m "refactor: Rename to BPC.Admin namespace for consistency"

# 13. Push (uncomment to run)
# git push origin v2
