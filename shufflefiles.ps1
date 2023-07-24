# Set the source and destination folders
$sourceFolderPath = "C:\Users\tranc\OneDrive\Pictures\fridge_slideshow"
$destinationFolderPath = "D:"

# Get the list of files in the source folder using case-insensitive regex filter
$files = Get-ChildItem -Path $sourceFolderPath | Where-Object { $_.Name -match '(?i)\.jpg$' }

# Define the regex pattern to match the ignored files (01.jpg through 24.jpg)
$ignoredFilesPattern = "(?i)^(0[1-9]|1[0-9]|2[0-4])\.jpg$"
$ignoredFilesRegex = [regex]::new($ignoredFilesPattern)

# Filter the files and ignore the ones that match the regex pattern
$ignoredFiles = $files | Where-Object { $ignoredFilesRegex.IsMatch($_.Name) -eq $true }
$filteredFiles = $files | Where-Object { $ignoredFilesRegex.IsMatch($_.Name) -eq $false }

# Copy the filtered files to the destination folder
foreach ($file in $ignoredFiles) {
    $destinationPath = Join-Path $destinationFolderPath $file.Name.ToLower()
    Copy-Item -Path $file.FullName -Destination $destinationPath
}

# Shuffle the remaining files randomly
$shuffledFiles = $filteredFiles | Get-Random -Count $filteredFiles.Count

# Loop through the shuffled files, generate a new name and copy them to the destination folder
foreach ($file in $shuffledFiles) {
    $newName = "File" + ($shuffledFiles.IndexOf($file) + 1).ToString("D2") + $file.Extension.ToLower()
    $destinationPath = Join-Path $destinationFolderPath $newName
    Copy-Item -Path $file.FullName -Destination $destinationPath
}
