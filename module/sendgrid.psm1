function main($param) {

    # 添付ファイルを読込み、Base64でエンコードする
    $attach = $param.att
    $attach_name = $param.att_name
    $attachContent = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($attach))

    $url = "https://api.sendgrid.com/v3/mail/send"

    # ヘッダーの内容はAPIキーとcontent-typeでほぼ固定
    $headers = @{
        "authorization" = "Bearer APIキー"
        "content-type" = "application/json"
    }

    $body = @{
        "personalizations" = @(
            @{
                "to" = @(
                    @{"email" = $param.to }
                )
                "bcc" = @(
                    @{"email" = $param.bcc }
                )
            }
        )
        "subject" = $param.subject
        "content" = @(
            @{"type" = "text/plain"
              "value" = "$($param.body)"}
        )
        "attachments" = @(
            @{
                "content" = $attachContent
                "filename" = $attach_name
            }
        )
        "from" = @{"email" = "no-reply-support@openupitengineer.co.jp"}
    }

    # オブジェクトをJsonへ変換する。その際、Depthを指定して、深い階層も変換されるようにする。
    $bodyJson = $body | ConvertTo-Json -Depth 20

    # JsonをUTF-8へ変換する。変換せずにPOSTすると、日本語が文字化けする。
    $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($bodyJson)

    Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $bodyBytes
}
