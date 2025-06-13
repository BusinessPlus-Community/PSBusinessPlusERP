Function ConvertTo-DotNetCookie {
    [CmdletBinding()]
    [OutputType([System.Net.Cookie])]
    param (
        [string]
        $CookieString
    )
}
