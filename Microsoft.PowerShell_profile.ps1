function MergeDev
{
    git fetch

    git merge origin/development
}

Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key Ctrl+p -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key Ctrl+n -Function HistorySearchForward

New-Alias vim nvim
New-Alias pn pnpm
New-Alias dn dotnet
New-Alias reboot restart-computer
# New-Alias git giti

function git
{
    if ($args.Length -gt 0 -and $args[0] -eq 'checkout')
    {
        & "C:\Program Files\OllieAve.GitImproved\net9.0\OllieAve.GitImproved.exe" -- @($args | Select-Object -Skip 1)
        return
    }
    elseif ($args.Length -gt 0 -and $args[0] -eq 'checkoutr')
    {
        $gitExe = (Get-Command git.exe -CommandType Application | Select-Object -First 1).Source

        $args[0] = 'checkout'

        & $gitExe @args
        return
    }
    elseif ($args.Length -gt 0 -and $args[0] -eq 'commit')
    {
        & "C:\Program Files\OllieAve.GitCommitImproved\Release\net9.0\win-x64\OllieAve.GitCommitImproved.exe"-- @($args | Select-Object -Skip 1)
        return
    }
    elseif ($args.Length -gt 0 -and $args[0] -eq 'commitr')
    {
        $gitExe = (Get-Command git.exe -CommandType Application | Select-Object -First 1).Source

        $args[0] = 'commit'

        & $gitExe @args
        return
    }

    $gitExe = (Get-Command git.exe -CommandType Application | Select-Object -First 1).Source
    & $gitExe @args
}

function cap
{
    git commit && git push
}

function sap
{
    git stage -A 
     
    echo 'Changes Staged'

    git commit

    echo 'Changes Committed'

    git push

    echo 'Changes Pushed'
}

# Alias for pj
function pf {
    pj
}

function pj {
    # Search directories inside C:\Code (depth: two levels)
    $dirs = Get-ChildItem -Path "C:\Code" -Directory -Recurse -Depth 0 | Select-Object -ExpandProperty FullName

    # Pipe directory list into fzf
    $selected = $dirs | fzf

    if ($selected) {
        Set-Location $selected
    }
}

function dnr {
    $projectDir = Get-ChildItem -Path . -Directory |
        Where-Object { $_.Name -match 'API$' } |
        Select-Object -First 1

    if (-not $projectDir) {
        throw "No directory ending with 'API' found."
    }

    $launchSettingsPath = Join-Path $projectDir.FullName 'Properties\launchSettings.json'
    $launchProfileArg = @()

    if (Test-Path $launchSettingsPath) {
        try {
            $launchSettings = Get-Content $launchSettingsPath -Raw | ConvertFrom-Json

            if ($launchSettings.profiles) {
                $httpsProfile = $launchSettings.profiles.PSObject.Properties |
                    Where-Object {
                        $_.Value.applicationUrl -match '^https://'
                    } |
                    Select-Object -First 1

                if ($httpsProfile) {
                    $launchProfileArg = @('--launch-profile', $httpsProfile.Name)
                }
            }
        }
        catch {
            # ignore malformed launchSettings.json
        }
    }

    dotnet run --project $projectDir.FullName @launchProfileArg
}

oh-my-posh init pwsh --config (Join-Path (Split-Path $PROFILE) '.posh-config.json') | Invoke-Expression
