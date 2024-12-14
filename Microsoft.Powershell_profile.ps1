# oh-my-posh config
oh-my-posh init pwsh --config  'C:\Users\ekule\AppData\Local\Programs\oh-my-posh\themes\1_shell.omp.json' | Invoke-Expression

function ghq-fzf {
  $repo = $(ghq list -full-path | fzf --reverse )
  if (-not [string]::IsNullOrEmpty($repo)) {
    cd $repo
  }
}

Set-PSReadLineKeyHandler -Chord Ctrl+k -ScriptBlock { 
  ghq-fzf 
  [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine() 
}

function history-fzf {
  $history=Get-Content (Get-PSReadlineOption).HistorySavePath 
  $history_reverse=$history[($history.Length-1)..0]
  $selection = $history_reverse | fzf --reverse --no-sort
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selection)
}

Set-PSReadLineKeyHandler -Chord Ctrl+h -ScriptBlock { history-fzf }

function get-git-repo {
  $repo=gh repo list --json sshUrl,nameWithOwner --jq '.[] | "\(.sshUrl)"' | fzf --reverse
  [Microsoft.PowerShell.PSConsoleReadLine]::Insert($repo)
}

Set-PSReadLineKeyHandler -Chord Ctrl+g -ScriptBlock { get-git-repo }


Clear-Host

function gst {
	git status $args
}

function ga {
	git add $args
}

function gaa {
	git add --all $args
}

function gcmsg {
	git commit -vm $args
}


function gb {
	git branch $args
}

function x {
	explorer.exe .
}

function tf {
	terraform
}

function tfa {
	terraform apply
}

function tfp {
	terraform plan
}

function tfd {
	terraform destroy
}

function tfi {
	terraform init
}

function tff {
	terraform fmt
}

function tfv {
	terraform validate
}

set-alias vi 'C:\Program Files\Vim\vim91\vim.exe'
set-alias vim 'C:\Program Files\Vim\vim91\vim.exe'

if ( Test-Path '~/.inshellisense/pwsh/init.ps1' -PathType Leaf ) { . ~/.inshellisense/pwsh/init.ps1 } 
