# リストをポップアップで表示
function list(){
	$list = ConvertFrom-Json -InputObject (Get-Content $PSScriptRoot\list.json -Encoding UTF8 -Raw)
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing

	$form = New-Object System.Windows.Forms.Form
	$form.Text = 'Select a Computer'
	$form.Size = New-Object System.Drawing.Size(300,200)
	$form.StartPosition = 'CenterScreen'

	$okButton = New-Object System.Windows.Forms.Button
	$okButton.Location = New-Object System.Drawing.Point(75,120)
	$okButton.Size = New-Object System.Drawing.Size(75,23)
	$okButton.Text = 'OK'
	$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$form.AcceptButton = $okButton
	$form.Controls.Add($okButton)

	$cancelButton = New-Object System.Windows.Forms.Button
	$cancelButton.Location = New-Object System.Drawing.Point(150,120)
	$cancelButton.Size = New-Object System.Drawing.Size(75,23)
	$cancelButton.Text = 'Cancel'
	$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$form.CancelButton = $cancelButton
	$form.Controls.Add($cancelButton)

	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,20)
	$label.Size = New-Object System.Drawing.Size(280,20)
	$label.Text = 'Please select a computer:'
	$form.Controls.Add($label)

	$listBox = New-Object System.Windows.Forms.ListBox
	$listBox.Location = New-Object System.Drawing.Point(10,40)
	$listBox.Size = New-Object System.Drawing.Size(260,20)
	$listBox.Height = 80

	foreach ($list_item in ($list.list)) {
		[void] $listBox.Items.Add($list_item)
	}

	$form.Controls.Add($listBox)

	$form.Topmost = $true

	$result = $form.ShowDialog()

	if ($result -eq [System.Windows.Forms.DialogResult]::OK)
	{
		$x = $listBox.SelectedItem
		return $x
	}else{
		exit
	}
}

function login($param){
	$azure_login_info = ConvertFrom-Json -InputObject (Get-Content $PSScriptRoot\azure_login_info.json -Encoding UTF8 -Raw)
	$cert = Get-ChildItem -Path cert:\LocalMachine -Recurse | Where-Object {$_.Thumbprint -eq $azure_login_info.CertificateThumbprint}

	#a環境ログイン
	if($param.tenant -eq "login_a")  {
		$login = Connect-AzureAD -CertificateThumbprint $cert.Thumbprint `
		-TenantId $azure_login_info.TenantId_a `
		-ApplicationId $azure_login_info.ApplicationId_a
		return $login.TenantDomain
	}
	#b環境ログイン
	elseif($param.tenant -eq "login_b") {
		$login = Connect-AzureAD -CertificateThumbprint $cert.Thumbprint `
		-TenantId $azure_login_info.TenantId_b `
		-ApplicationId $azure_login_info.ApplicationId_b
		return $login.TenantDomain
	}
	#c環境ログイン
	elseif($param.tenant -eq "login_c") {
		$login = Connect-AzureAD -CertificateThumbprint $cert.Thumbprint `
		-TenantId $azure_login_info.TenantId_c `
		-ApplicationId $azure_login_info.ApplicationId_c
		return $login.TenantDomain
	}
	#d環境ログイン
	elseif($param.tenant -eq "login_d") {
		$login = Connect-AzureAD -CertificateThumbprint $cert.Thumbprint `
		-TenantId $azure_login_info.TenantId_d `
		-ApplicationId $azure_login_info.ApplicationId_d
		return $login.TenantDomain
	}
}

# b2cユーザー作成
function create($param) {

	if(!$param.pass){
		#Password生成
		$Pa = -Join (Get-Random -Count 3 -input 0,1,2,3,4,5,6,7,8,9)
		$ss = -Join (Get-Random -Count 3 -input a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z)
		$word = -Join (Get-Random -Count 3 -input A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z)
		$Password = $Pa + $ss + $word
	}else{
		$Password = $param.pass
	}

	$SignInNames = @(
		(New-Object `
			Microsoft.Open.AzureAD.Model.SignInName `
			-Property @{Type = "emailAddress"; Value = $param.mail})
	)

	$PasswordProfile = New-Object `
		-TypeName Microsoft.Open.AzureAD.Model.PasswordProfile `
		-Property @{ 
			'Password' = $Password;
			'ForceChangePasswordNextLogin' = $false;
		};

	# 作成実行
	$create = New-AzureADUser `
		-DisplayName $param.mail `
		-department "$($param.class)," `
		-CreationType "LocalAccount" `
		-AccountEnabled $true `
		-PasswordProfile $PasswordProfile `
		-SignInNames $SignInNames
	return $Password
}