Invoke-Expression (&starship init powershell)

function fzf-cd-src {
   $selected_dir = ghq list -p | fzf --reverse

   if ($selected_dir) {
    Set-Location $selected_dir
    Clear-Host
    [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen();
   }
}

function fzf-history {
   $selected = cat (Get-PSReadlineOption).HistorySavePath | fzf --reverse --tac

   if ($selected) {
      [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
   }

}

function fzf-gh {
   $selected = gh repo list --json sshUrl | ConvertFrom-Json | ForEach-Object { "$($_.sshUrl)" } | fzf --reverse

   if ($selected) {
      [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
   }
}

function gst {
	git status $args
}

Set-PSReadLineKeyHandler -Key Ctrl+k -ScriptBlock { fzf-cd-src }
Set-PSReadLineKeyHandler -Key Ctrl+h -ScriptBlock { fzf-history }
Set-PSReadLineKeyHandler -Key Ctrl+g -ScriptBlock { fzf-gh }

Set-Alias x explorer

$ENV:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
