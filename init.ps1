$dotfilesPath = "$PSScriptRoot"
$homePath = $env:USERPROFILE


# シンボリックリンクを作成する
function New-Symlink {
    param (
        [string]$source,
        [string]$destination
    )

    # 既にファイルが存在する場合は確認
    if (Test-Path $destination) 
    {
        $response = Read-Host "File or directory already exists: $destination. Do you want to delete it and create a new symlink? (y/n)"
        if ($response -eq 'y') {
            Remove-Item $destination -Force
            Write-Host "Existing file or directory removed: $destination"
            New-Item -ItemType SymbolicLink -Path $destination -Target $source
            Write-Host "Created symlink: $destination -> $source"
        } else {
            Write-Host "Skipped symlink creation for: $destination"
        }
    } 
    else
    {
        New-Item -ItemType SymbolicLink -Path $  -Target $source
        Write-Host "Created symlink: $destination -> $source"
    }
}

New-Symlink "$dotfilesPath\Microsoft.PowerShell_profile.ps1" "$homePath\Documents\Powershell\microsoft.PowerShell_profile.ps1"
New-Symlink "$dotfilesPath\.config\starship\starship.toml" "$homePath\.config\starship\starship.toml"
