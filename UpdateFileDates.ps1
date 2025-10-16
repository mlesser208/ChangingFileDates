# PowerShell script to update file modification dates
# Sets files to different times within the same day last week
# Downloaded data folders get the same timestamp

param(
    [string]$TargetPath = "C:\Users\matth\Desktop\Project3"
)

# Calculate a date from last week (let's use Thursday of last week)
$baseDate = (Get-Date).AddDays(-4)  # Thursday of last week
$baseDate = $baseDate.Date  # Set to midnight

Write-Host "Setting file dates to: $baseDate" -ForegroundColor Green

# Function to set file date
function Set-FileDate {
    param(
        [string]$FilePath,
        [datetime]$NewDate
    )
    
    if (Test-Path $FilePath) {
        $file = Get-Item $FilePath
        $file.LastWriteTime = $NewDate
        Write-Host "Updated: $FilePath -> $NewDate" -ForegroundColor Yellow
    }
}

# Set dates for individual files (different times on the same day)
$individualFiles = @(
    "Screenshot 2025-10-16 133826.png",
    "Screenshot 2025-10-16 133851.png",
    "Screenshot 2025-10-16 133910.png",
    "study1_addresses_nearest_greens.gpkg",
    "desktop.ini"
)

Write-Host "`nUpdating individual files with different times..." -ForegroundColor Cyan
$timeOffset = 0
foreach ($file in $individualFiles) {
    $filePath = Join-Path $TargetPath $file
    $newTime = $baseDate.AddHours(9).AddMinutes($timeOffset * 15)  # Start at 9 AM, 15 min intervals
    Set-FileDate -FilePath $filePath -NewDate $newTime
    $timeOffset++
}

# Set Project3MLesser.pdf to October 13th
$pdfDate = $baseDate.AddDays(1)  # October 13th
$pdfTime = $pdfDate.AddHours(10).AddMinutes(30)  # 10:30 AM on the 13th
$pdfPath = Join-Path $TargetPath "Project3MLesser.pdf"
Write-Host "Setting Project3MLesser.pdf to: $pdfTime" -ForegroundColor Magenta
Set-FileDate -FilePath $pdfPath -NewDate $pdfTime

# Set dates for downloaded data folders (same timestamp for all files in each folder)
Write-Host "`nUpdating downloaded data folders with same timestamps..." -ForegroundColor Cyan

# Project3Data folder - all files get same timestamp
$project3DataTime = $baseDate.AddHours(14).AddMinutes(30)  # 2:30 PM
$project3DataPath = Join-Path $TargetPath "Project3Data"
if (Test-Path $project3DataPath) {
    Write-Host "Setting Project3Data folder files to: $project3DataTime" -ForegroundColor Magenta
    Get-ChildItem -Path $project3DataPath -File | ForEach-Object {
        Set-FileDate -FilePath $_.FullName -NewDate $project3DataTime
    }
}

# Study2_Allentown folder - all files get same timestamp
$allentownTime = $baseDate.AddHours(22).AddMinutes(15)  # 10:15 PM
$allentownPath = Join-Path $TargetPath "Study2_Allentown"
if (Test-Path $allentownPath) {
    Write-Host "Setting Study2_Allentown folder files to: $allentownTime" -ForegroundColor Magenta
    Get-ChildItem -Path $allentownPath -File -Recurse | ForEach-Object {
        Set-FileDate -FilePath $_.FullName -NewDate $allentownTime
    }
    
    # Set the folder itself to a slightly later time
    $folderTime = $allentownTime.AddMinutes(5)  # 5 minutes after the files
    Write-Host "Setting Study2_Allentown folder itself to: $folderTime" -ForegroundColor Magenta
    $folder = Get-Item $allentownPath
    $folder.LastWriteTime = $folderTime
}

Write-Host "`nFile date update completed!" -ForegroundColor Green
Write-Host "Summary:" -ForegroundColor White
Write-Host "- Individual files: Different times on $($baseDate.ToString('yyyy-MM-dd'))" -ForegroundColor White
Write-Host "- Project3MLesser.pdf: Set to $($pdfTime.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor White
Write-Host "- Project3Data folder: All files set to $($project3DataTime.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor White
Write-Host "- Study2_Allentown folder: All files set to $($allentownTime.ToString('yyyy-MM-dd HH:mm')), folder itself to $($folderTime.ToString('yyyy-MM-dd HH:mm'))" -ForegroundColor White
