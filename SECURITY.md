# Security Policy

## Supported Versions

Currently supported versions of BPC.Admin:

| Version | Supported          |
| ------- | ------------------ |
| 0.2.x   | :white_check_mark: |
| < 0.2   | :x:                |

## Reporting a Vulnerability

The BusinessPlus Community takes security vulnerabilities seriously. We appreciate your efforts to responsibly disclose your findings.

### How to Report

To report a security vulnerability, please:

1. **DO NOT** create a public GitHub issue
2. Email the security team at: security@businesspluscommunity.org (if available)
3. Or create a private security advisory on GitHub:
   - Go to the Security tab
   - Click on "Report a vulnerability"
   - Fill out the security advisory form

### What to Include

Please include the following information:
- Type of vulnerability
- Full paths of source file(s) related to the issue
- Location of the affected source code (tag/branch/commit or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 5 business days
- **Resolution Timeline**: Depends on severity
  - Critical: 7-14 days
  - High: 14-30 days
  - Medium: 30-60 days
  - Low: 60-90 days

## Security Best Practices

When using BPC.Admin:

1. **Credentials**: Never hardcode credentials in scripts
2. **Permissions**: Use least-privilege accounts
3. **Validation**: Always validate input parameters
4. **Logging**: Be careful not to log sensitive information
5. **Updates**: Keep the module updated to the latest version

## Known Security Considerations

- The module stores authentication cookies for BusinessPlus sessions
- Ensure proper file permissions on cookie storage locations
- Use secure connections (HTTPS) when communicating with BusinessPlus servers