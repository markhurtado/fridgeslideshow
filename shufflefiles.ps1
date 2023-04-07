# Set the source and destination folders
$sourceFolder = "C:\Users\tranc\OneDrive\Pictures\fridge_slideshow"
$destinationFolder = "D:"

# Get the list of files in the source folder
$files = Get-ChildItem $sourceFolder

# Shuffle the files randomly
$shuffledFiles = $files | Get-Random -Count $files.Count

# Loop through the shuffled files and rename them, then copy them to the destination folder
for ($i = 0; $i -lt $shuffledFiles.Count; $i++) {
    $file = $shuffledFiles[$i]
    $newName = "File" + ($i + 1) + $file.Extension
    $destinationPath = Join-Path $destinationFolder $newName
    Copy-Item $file.FullName $destinationPath
}
