<#
.Synopsis
Notifications Powershell Module
.Description
Subscribe to and get notifications
#>

function Add-NotificationSubscription {
    [CmdletBinding()]
    param (
        [string]$ContactType,
        [Parameter(Mandatory=$true)]
        [String]$Destination,
        [string]$Component,
        [string]$MessageType,
        [string[]]$Tags
    )
    
    # TODO: Check each parameter entered by the user and warn them if their
    # value is not valid

    # TODO: Insert into SQL

    # TODO: Add the other params to the CLI message if they were used
    $Destination + ' will now receive notifications'
}

function Get-NotificationSubscription {
    [CmdletBinding()]
    param (
        [string]$ContactType,
        [String]$Destination,
        [string]$Component,
        [string]$MessageType,
        [string[]]$Tags,
        [string]$CreatedBy
    )

    # TODO: Check each parameter entered by the user and warn them if their
    # value is not valid

    # TODO: Get this from SQL
    $result = '
    user, runruh, build, error, , runruh
    channel, new-feature, , , new-feature, runruh
    '

    $result
}

function Send-Notification {
    [CmdletBinding()]
    param (
        [string]$Component,
        [string]$MessageType,
        [string[]]$Tags,
        [string]$ID,
        [Parameter(Mandatory=$true)]
        [string]$Message
        
    )
    
    # TODO: Check each parameter entered by the user and warn them if their
    # value is not valid. Although these seem like they'll be sent by scripts.
    
    # TODO: Insert into SQL and a query failure message
    'Message added to notification history'

    # TODO: Get colors from SQL MessageType table
    $msgTypeColors = @{
        'info' = 'good';
        'warning' = 'warning';
        'error' = 'danger'
    }

    # TODO: If we can link to msgs from some Components, we could get URLs from SQL and prepend them to the ID here

    # TODO: Get channel(s) from SQL based on params
    $channel = Get-Content ..\Channel.txt

    # TODO: Figure out where to put this config file or add a Token param
    $token = Get-Content ..\Token.txt
    
    $json = "
    {
        `"channel`": `"$channel`",
        `"fallback`": `"$Message $ID`",
        `"attachments`": [
            {
                `"title`": `"$Component $MessageType -- $ID`",
                `"text`": `"$Message`",
                `"color`": `"$($msgTypeColors[$MessageType])`"
            }
        ]
    }
    "

    $response = Invoke-WebRequest `
        -Headers @{
            'Authorization' = "Bearer $token";
            'Content-type' = 'application/json' 
        } `
        -Body $json `
        -Method Post `
        -Uri 'https://slack.com/api/chat.postMessage'

    # Slack responds with 200 for some failed msgs (bad channel). Converting
    # their json body to an object and checking 'ok' seems to work. Maybe we
    # should check for 'error' instead though.
    $content = $response.Content | ConvertFrom-Json

    if ($response.StatusCode -eq 200 -and $content.ok) {
        'Message posted to Slack'
    }
    else {
        $response
        "`r`nCouldn't post message to Slack"
    }
}


# SIG # Begin signature block
# MIIFZAYJKoZIhvcNAQcCoIIFVTCCBVECAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUl0M2fvhd+UBaF/qbNSNSTo7D
# O16gggMCMIIC/jCCAeagAwIBAgIQGTNat6GS3olKYA+d6ANbSjANBgkqhkiG9w0B
# AQsFADAXMRUwEwYDVQQDDAxSZXViZW4gVW5ydWgwHhcNMTkwMTI4MjEzNTI3WhcN
# MjAwMTI4MjE1NTI3WjAXMRUwEwYDVQQDDAxSZXViZW4gVW5ydWgwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCYyr1nljrm2njPU6TRgLf5ODpGqo8ejm4m
# txsTmvZcInX0dXI6BViiTGjEt6OK3Knx0hjZrZdMADaGUcEOGCvmHqm578eh5ay/
# kCNJ5okC4TKoQ1SnJelYLsM40MUuiOoYXqiDWZCDk2YOQUAqmUPzPdJAl9ji3FVb
# M1i4RAiEVKMn+PJ9eVewecflpQbPkZpXkNj+zoD/OWtthX5Gb4S01c+8mV5xsQ6M
# ZgEK+ufxc7rMzYcPvE4Zw3oz9ccQr9MFhFU1A1qEXiPi1ItdCURbajl+2DNdRTAu
# ClalsREs2e+Lg1Tt4aSVfuRtRBWe02D9FjUd2VWxF7zm0jXW+1DZAgMBAAGjRjBE
# MA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU
# OAsdQiUwP/anbzKy8buyzQK4L9wwDQYJKoZIhvcNAQELBQADggEBAIfARP859at/
# 9FnghAhad8cxwV/PUmgQVDujXDd92xqc0ZKrqUR5bLZ50owhWJlu4l71+o6OGKRv
# DNBa7i+PyocwrHm8IbS/z39RGkxiE5VRnLEWRjNd+iS8m7yxJK4GADEEYwL1IEUG
# S/eZQ/E27uP3RrPKUrLPagTzQTwK886CE2KmDzLEThR+Q/Us0VEF/7N6eNYrPnCu
# nSYsfG0G3aHAmQyLJh5bWKzlK9+RESpOlbZCAmrH8zmN8SRI0Ln89CAilWsUQvHn
# quniAWN/noCdx68I97Jr2Z+usdmKn7aE4u1TgAqRxOcCvRvCka1gvFbopuDkOsqG
# M1NSWre0JI0xggHMMIIByAIBATArMBcxFTATBgNVBAMMDFJldWJlbiBVbnJ1aAIQ
# GTNat6GS3olKYA+d6ANbSjAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUQVgBPYbCvEAOW5WiyvCd
# tQMgE3IwDQYJKoZIhvcNAQEBBQAEggEAIXEMQgTQG8LNf3A/q1DLvo3DVyhyqaHj
# MgwWWIwsgfrQy1illxEOCq54RPhOhCAd+rkkCJyEEtKUXHfwcLvTVLvkQxbYRURw
# E/9ra83nyJXlt10udpCyQe5nRKaTm36UMuzMZGR/T/bAgyftEjsZOAV+5Lg39aP5
# paykW+9PfTW5BphkBFzPeCET8wiqJq0ZrtCRv4c7J8YQCjQ426YNRBrmb3iJs7yE
# J+15scPM5xR2eukHYkyEs4TSZ8o4zeJz0gaT8YgZ5hSTgdjSxU/O1URpuQJb9se+
# N3fm6rQG7aayqENMlXWeirZ7Yn2o8iCD7MW7VFiqXpHu0jrSYU+GyA==
# SIG # End signature block
