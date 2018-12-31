# Hmmm... usgs api's...
# https://waterservices.usgs.gov/rest/IV-Service.html

Function Get-Flow {
[CmdLetBinding()]
Param(
    [switch]$WestBranch,
    [switch]$Saco
)

    # URL's
    $Nob_WestBranch = 'http://www.h2oline.com/default.aspx?pg=si&op=235114'
    $Saco_Steeps = 'http://www.h2oline.com/srcs/231196.html'    

    if ($WestBranch) {
        $URI = $Nob_WestBranch
    }
    if ($Saco) {
        $URI = $Saco_Steeps
    }
    
    $WebRequest = Invoke-WebRequest -Uri $URI

    $RiverFlow = $WebRequest.ParsedHtml.getElementsByTagName('p') | Select-Object -ExpandProperty outertext

    Write-Output $RiverFlow
}
