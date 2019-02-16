$new_size = 3072
Write-Host "Changing page file size to $new_size MB"
$pagefile_settings = Get-CimInstance -Class Win32_PageFileSetting
$pagefile_settings.InitialSize = $new_size
$pagefile_settings.MaximumSize = $new_size
Set-CimInstance -CimInstance $pagefile_settings