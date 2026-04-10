$mode    = $args[0]
$SCRIPTNAME = 'untrack-ignored'
$PRINT   = '--print'
$RM      = '--rm'
$RESTORE = '--restore'

git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'Not a git repository.'
    exit 1
}

$gitRoot = git rev-parse --show-toplevel
$stateFile = "$gitRoot/.git/untrack-ignored.removed"

$files = git ls-files | git check-ignore --stdin | ForEach-Object {
    $_ -replace '^"|"$' -replace '\\r$'
}

if (($mode -eq $PRINT -or $mode -eq $RM) -and !$files) 
{
    Write-Host 'No wrongfully tracked files found.'
    exit 0
}

switch ($mode) {
    $PRINT
    {
        $files
        Write-Host "$($files.Count) wrongfully tracked files"
    }
    $RM
    {
        $removed = @()
        $files | ForEach-Object
        {
            git rm --cached $_
            if ($LASTEXITCODE -eq 0) { $removed += $_ }
        }
        if ($removed)
        {
            $removed | Set-Content $stateFile
        }
        Write-Host "$($removed.Count) files removed"
    }
    $RESTORE
    {
        if (!(Test-Path $stateFile))
        {
            Write-Host 'No deletions to restore.'
            break;
        }
        $removed = Get-Content $stateFile
        if (!$removed)
        {
            Write-Host 'Nothing to restore.'
            break;
        }
        $stagedDeletions = git diff --name-only --cached --diff-filter=D | ForEach-Object { $_.TrimEnd("`r") }
        $restoredCount = 0
        $removed | ForEach-Object {
            if ($stagedDeletions -contains $_)
            {
                Write-Host "restore $_"
                git restore --staged $_
                $restoredCount++
            }
            else
            {
                Write-Host "skip $_ (already committed)"
            }
        }
        Remove-Item $stateFile
        Write-Host "$restoredCount files restored"
    }
    default
    {
        Write-Host 'Usage:'
        Write-Host "  $SCRIPTNAME --print    List all tracked files that should be ignored"
        Write-Host "  $SCRIPTNAME --rm   Untrack all files that are gitignored and should be untracked (keeps files on disk)"
        Write-Host "  $SCRIPTNAME --restore   Undo the last --rm"
    }
}
