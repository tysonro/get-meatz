# Adapted from: http://ramblingcookiemonster.github.io/Building-A-PowerShell-Module/

# Get public, private and class function definition files
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue -Recurse)
$Classes = @(Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 -ErrorAction SilentlyContinue -Recurse)

# Dot source functions
ForEach ($Import in @($Public + $Private + $Classes)) {
    Try {
        . $Import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($Import.fullname): $_"
    }
}

# Export public functions only
Export-ModuleMember -Function $Public.Basename
