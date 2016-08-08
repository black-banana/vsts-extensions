[System.Net.WebClient]$webClient = New-Object System.Net.WebClient
$webClient.UseDefaultCredentials = $true

function DownloadFile($fileUrl,$downloadFolder){
    Write-Host "DownloadFile from $fileUrl to $downloadFolder"
    $webClient.DownloadFile($fileUrl,$downloadFolder)
}

function GetJsonResult($jsonUrl){
    Write-Host "GetJsonResult $jsonUrl"
    return ConvertFrom-Json $webClient.DownloadString($jsonUrl)
}

function GetLatestBuildId($projectUrl, $buildDefId){
    Write-Host "GetLatestBuildId from $projectUrl $buildDefId"
    $getLatestBuildUrl = "$projectUrl/_apis/build/builds?definitions=$buildDefId&statusFilter=completed&`$top=1&api-version=2.0"
    $latestBuildResult = GetJsonResult $getLatestBuildUrl
    return $latestBuildResult[0].value.id
}

function GetBuildArtifacts($projectUrl, $buildId){
    Write-Host "GetBuildArtifacts from $projectUrl $buildId"
    $getBuildArtifacts = "$projectUrl/_apis/build/builds/$buildId/artifacts"
    $buildArtifactsResult = GetJsonResult $getBuildArtifacts
    return $buildArtifactsResult
}

function DownloadBuildArtifacts($artifacts,$outputFolder,$artifactNames){    
    Write-Host "DownloadBuildArtifacts into $outputFolder"
    foreach($artifact in $artifacts) {
        if($artifactNames.Length -gt 0 -and -not $artifactNames.Contains($artifact.value.name)) {
            continue
        }    
        $downloadUrl = "$($artifact.value.resource.downloadUrl)"
        DownloadFile $downloadUrl $outputFolder        
    }
}

function DownloadLatestBuildArtifacts([string]$projectUrl, [string]$buildDefId, [string]$outputFolder, [string[]]$artifactNames) {
    Write-Output "DownloadLatestBuildArtifacts from $projectUrl $buildDefId"
    $buildId = GetLatestBuildId $projectUrl $buildDefId
    $artifacts = GetBuildArtifacts $projectUrl $buildId
    DownloadBuildArtifacts $artifacts $outputFolder $artifactNames
}