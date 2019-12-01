Write-Host "Checking for elevation... "                                                                                                                                         #Check Admin Permissions
$CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent()) 
if (($CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) -eq $false) 
{ 
    $ArgumentList = "-noprofile -noexit -file `"{0}`" -Path `"$Path`" -MaxStage $MaxStage" 
    If ($ValidateOnly) { $ArgumentList = $ArgumentList + " -ValidateOnly" } 
    If ($SkipValidation) { $ArgumentList = $ArgumentList + " -SkipValidation $SkipValidation" } 
    If ($Mode) { $ArgumentList = $ArgumentList + " -Mode $Mode" } 
    Write-Host "elevating" 
    Start-Process powershell.exe -Verb RunAs -ArgumentList ($ArgumentList -f ($myinvocation.MyCommand.Definition)) -Wait 
    Exit 
}  
write-host "Success" 

$ProcessActive = Get-Process dapscoin-qt -ErrorAction SilentlyContinue                                                                                                           #Check Process "dapscoin-qt.exe"
if($ProcessActive -eq $null)
{
$PATH = "c:\PROGRA~1\Dapscoin\Updater"
if (!(Test-Path $PATH)) {New-Item -Path $PATH -ItemType Directory > $null}

cp "$env:APPDATA\Dapscoin\wallet.dat" "$env:APPDATA\Dapscoin\Backup$(((get-date).ToUniversalTime()).ToString("yyyy-MM-dd_hh.mm.ss"))_Wallet.dat" -Force                          #save Wallet.dat
Write-Host "Wallet.dat has been saved!"

Write-Host "Downloading latest update.`nPlease wait..."                                                                                                                          #Download latest Update
$client = new-object System.Net.WebClient
$client.DownloadFile("https://github.com/DAPSCoin/DAPSCoin/releases/download/1.0.4/master_windowsx64-v1.0.4.6.zip", "c:\PROGRA~1\Dapscoin\Updater\master_windowsx64_latest.zip")

Write-Host "Download completed.`nUnzipping..."                                                      
Add-Type -AssemblyName System.IO.Compression.FileSystem                                                                                                                          #unzip the zipfile
[System.IO.Compression.ZipFile]::ExtractToDirectory("c:\PROGRA~1\Dapscoin\Updater\master_windowsx64_latest.zip", "c:\PROGRA~1\Dapscoin\Updater\master_windowsx64_latest")

Write-Host "Replacing dapscoin-qt.exe file with the new one..."
cp "c:\PROGRA~1\Dapscoin\Updater\master_windowsx64_latest\dapscoin-qt.exe" "c:\PROGRA~1\Dapscoin" -Force                                                                         #copy new dapscoin-qt.exe to old "Program Files" Location

Write-Host "Update completed, startup your Wallet again, get a coffee and be patient ;)"
Write-Host -NoNewLine "Press any key to continue...";
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}
else
{
Write-Host "Your DAPSCoin Wallet is still running. `nPlease Backup your Wallet, copy your wallet.dat to a safe place and close your wallet before proceed the update."
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
}
exit