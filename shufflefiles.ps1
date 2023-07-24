# Set the source and destination folders
$sourceFolderPath = "C:\Users\tranc\OneDrive\Pictures\fridge_slideshow"
$destinationFolderPath = "D:"

# Get the list of files in the source folder using case-insensitive regex filter
$files = Get-ChildItem -Path $sourceFolderPath | Where-Object { $_.Name -match '(?i)\.jpg$' }


# Change the file extensions in the source folder to lowercase
# foreach ($file in $files) {
#     $extension = $file.Extension
#     if ($extension -ne $extension.ToLower()) {
#         $newPath = $file.FullName.Replace($extension, $extension.ToLower())
#         Rename-Item -Path $file.FullName -NewName $newPath -ErrorAction SilentlyContinue
#     }
# }

# # Ignore the files named 01.jpg through 24.jpg
# $ignoredFileList = @("01.jpg", "02.jpg", "03.jpg", "04.jpg", "05.jpg", "06.jpg", "07.jpg", "08.jpg", "09.jpg", "10.jpg", "11.jpg", "12.jpg", "13.jpg", "14.jpg", "15.jpg", "16.jpg", "17.jpg", "18.jpg", "19.jpg", "20.jpg", "21.jpg", "22.jpg", "23.jpg", "24.jpg")
# $ignoredFiles = $files | Where-Object { $ignoredFileList -contains $_.Name }
# $filteredFiles = $files | Where-Object { $ignoredFileList -notcontains $_.Name }

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
