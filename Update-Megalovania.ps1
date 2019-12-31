<#
    .SYNOPSIS
        Changes the Megalovania song on each death in Undertale
    .DESCRIPTION
        Everytime you die in Undertale, the Megalovania song will be changed to one in the folder you specify.
    .PARAMETER IniFile
        The full paul to the undertale.ini file. defaults to %LOCALAPPDATA%\UNDERTALE\undertale.ini
    .PARAMETER OutFile
        The full path to the mus_zz_megalovania.ogg file in your Undertale installation directory.
    .PARAMETER SourcePath
        The full path to the folder that contains ogg files with which to replace mus_zz_megalovania.ogg
    .PARAMETER Random
        Use random selection in stead of ordered selection.
    .NOTES
        This currently only supports Undertale on Windows.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [String]
    $IniFile = (Join-Path $env:LOCALAPPDATA "UNDERTALE\undertale.ini"),

    [Parameter()]
    [String]
    $OutFile = "D:\Steam\steamapps\common\Undertale\mus_zz_megalovania.ogg",

    [Parameter()]
    [String]
    $SourcePath = "D:\media\Megalovania",

    [Parameter()]
    [switch]
    $Random
)

$LastCount = -1
$Index = -1

$SoundFiles = Get-ChildItem -Path $SourcePath -Filter "*.ogg"

$BaseArray = 0..($SoundFiles.Count - 1)
[System.Collections.Generic.List[Int32]]$AvailableList = $BaseArray.Clone()

while ($true) {
    try {
        $Result = Get-Content $IniFile -ErrorAction Stop | Select-String "gameover"
        [int]$Count = ($Result.Line -split '=')[1] -replace '"'
        if($LastCount -eq -1) {
            $LastCount = $Count
            Write-Host "Set LastCount to $LastCount"
            continue
        }
        if ($Count -ne $LastCount) {
            $LastCount = $Count
            Write-Host "Set LastCount to $LastCount"
            if($Random) {
                Write-Host 'Random'
                $Index = $AvailableList | Get-Random
                $null = $AvailableList.Remove($Index)
                if($AvailableList.Count -eq 0){
                    [System.Collections.Generic.List[Int32]]$AvailableList = $BaseArray.Clone()
                }
            } elseif ($Index -ge $SoundFiles.Count - 1) {
                Write-Host 'Rewind'
                $Index = 0
            } else {
                Write-Host 'Iterate'
                $Index ++
            }
            Write-Host "Index: $Index"
            $File = $SoundFiles[$Index]
            Copy-Item -Force -LiteralPath $File.FullName -Destination $OutFile -Verbose
        }
        Start-Sleep -Milliseconds 500
    } catch {}
}