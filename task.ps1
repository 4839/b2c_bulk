# ログ出力
# Start-Transcript ".\log\ins$(Get-Date -Format("yyyy-MM-dd-hh-mm-ss")).log"

# モジュール読み込み
Import-Module -Name ".\module\b2c_ope.psm1"

# CSV読み込み
$import_csv_path = ".\data.csv"
$datas = Import-Csv $import_csv_path -Encoding UTF8

# ポップアップオブジェクト作成
$wsobj = new-object -comobject wscript.shell

$output = $datas | ConvertTo-Json
Write-Host $output
if($wsobj.popup("このリストで問題ないですか？",0,"確認",4) -ne 6){
	exit;
}

# 作成するB2Cテナントを選択
$tenant = list

#ログイン
login $tenant


# 処理結果格納配列
$results = @()
foreach ($data in $datas) {
	#B2C作成
	Write-Output "b2c_create.."
	$param = [PSCustomObject]@{
		mail = $data.mail
		class = $data.class
		pass = $null
	}

	try{
		$create_result = create $param
	}catch{
		$wsobj.popup("登録エラー")
		$create_result = $_
		continue
	}

	# 処理結果を、配列に格納
	$results += [PSCustomObject]@{
		mail = $EmailAddress
		pass = $create_result
	}
}

$wsobj.popup("処理完了")
$success = @"
お疲れ様です。
ただいまB2C登録が完了いたしました。
"@

# クリップボードに上記返答分を保存
Set-Clipboard $success

# 処理結果配列をCSV出力
$result_csv_path = ".\result\ins_$login_tenant$(get-date -Format("yyyy-MM-dd-hh-mm-ss")).csv"
$results | Export-Csv $result_csv_path -Encoding Default -NoTypeInformation
Invoke-Item $result_csv_path

