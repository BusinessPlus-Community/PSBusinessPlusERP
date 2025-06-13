$manifest = Get-Content "BPC.Admin/PSBusinessPlusERP.psd1" -Raw
$manifest = $manifest -replace "CompanyName\s*=\s*'Unknown'", "CompanyName = 'BusinessPlus Community'"
$manifest = $manifest -replace "Copyright\s*=\s*'\(c\) 2024 Zach Birge\. All rights reserved\.'", "Copyright = '(c) 2024 BusinessPlus Community. All rights reserved. Licensed under GPL-3.0'"
$manifest | Set-Content "BPC.Admin/PSBusinessPlusERP.psd1" -NoNewline
