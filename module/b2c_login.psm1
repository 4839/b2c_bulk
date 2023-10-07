
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

Export-ModuleMember -Function * -Variable *