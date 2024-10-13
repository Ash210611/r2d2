#Set Folder Permissions
$files = @("C:\Program Files\Mozilla Firefox\mozilla.cfg","C:\AutoConfig\First Run","C:\AutoConfig\mozilla.cfg")
$files | % {
    $path = $_
    $acl = Get-Acl $path
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("BUILTIN\Users","FullControl", "None","None","Allow")
    $acl.SetAccessRule($AccessRule)
    $acl | Set-Acl $path
}
