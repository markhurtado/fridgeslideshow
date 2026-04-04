Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

function Get-UniquePreferredFiles {
    param(
        [System.Collections.Generic.List[System.IO.FileInfo]]$Files
    )

    # Keep only one of 01.jpg to 24.jpg if duplicates exist across source folders.
    $result = @()
    $seen = @{}

    foreach ($file in ($Files | Sort-Object Name, FullName)) {
        $key = $file.Name.ToLowerInvariant()
        if (-not $seen.ContainsKey($key)) {
            $seen[$key] = $true
            $result += $file
        }
    }

    return $result
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Fridge Slideshow Shuffler"
$form.Size = New-Object System.Drawing.Size(760, 520)
$form.StartPosition = "CenterScreen"

$lblSources = New-Object System.Windows.Forms.Label
$lblSources.Text = "Source folders"
$lblSources.Location = New-Object System.Drawing.Point(20, 20)
$lblSources.AutoSize = $true
$form.Controls.Add($lblSources)

$listSources = New-Object System.Windows.Forms.ListBox
$listSources.Location = New-Object System.Drawing.Point(20, 45)
$listSources.Size = New-Object System.Drawing.Size(560, 220)
$form.Controls.Add($listSources)

$btnAddSource = New-Object System.Windows.Forms.Button
$btnAddSource.Text = "Add folder"
$btnAddSource.Location = New-Object System.Drawing.Point(600, 45)
$btnAddSource.Size = New-Object System.Drawing.Size(130, 30)
$form.Controls.Add($btnAddSource)

$btnRemoveSource = New-Object System.Windows.Forms.Button
$btnRemoveSource.Text = "Remove selected"
$btnRemoveSource.Location = New-Object System.Drawing.Point(600, 85)
$btnRemoveSource.Size = New-Object System.Drawing.Size(130, 30)
$form.Controls.Add($btnRemoveSource)

$btnClearSources = New-Object System.Windows.Forms.Button
$btnClearSources.Text = "Clear all"
$btnClearSources.Location = New-Object System.Drawing.Point(600, 125)
$btnClearSources.Size = New-Object System.Drawing.Size(130, 30)
$form.Controls.Add($btnClearSources)

$lblDestination = New-Object System.Windows.Forms.Label
$lblDestination.Text = "Destination folder (USB root)"
$lblDestination.Location = New-Object System.Drawing.Point(20, 290)
$lblDestination.AutoSize = $true
$form.Controls.Add($lblDestination)

$txtDestination = New-Object System.Windows.Forms.TextBox
$txtDestination.Location = New-Object System.Drawing.Point(20, 315)
$txtDestination.Size = New-Object System.Drawing.Size(560, 30)
$form.Controls.Add($txtDestination)

$btnBrowseDestination = New-Object System.Windows.Forms.Button
$btnBrowseDestination.Text = "Browse"
$btnBrowseDestination.Location = New-Object System.Drawing.Point(600, 313)
$btnBrowseDestination.Size = New-Object System.Drawing.Size(130, 30)
$form.Controls.Add($btnBrowseDestination)

$chkRecurse = New-Object System.Windows.Forms.CheckBox
$chkRecurse.Text = "Include subfolders"
$chkRecurse.Location = New-Object System.Drawing.Point(20, 355)
$chkRecurse.Checked = $true
$chkRecurse.AutoSize = $true
$form.Controls.Add($chkRecurse)

$chkClearDest = New-Object System.Windows.Forms.CheckBox
$chkClearDest.Text = "Delete existing JPG files in destination first"
$chkClearDest.Location = New-Object System.Drawing.Point(20, 380)
$chkClearDest.Checked = $false
$chkClearDest.AutoSize = $true
$form.Controls.Add($chkClearDest)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Shuffle and copy to USB"
$btnRun.Location = New-Object System.Drawing.Point(20, 420)
$btnRun.Size = New-Object System.Drawing.Size(220, 36)
$form.Controls.Add($btnRun)

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "Close"
$btnClose.Location = New-Object System.Drawing.Point(260, 420)
$btnClose.Size = New-Object System.Drawing.Size(90, 36)
$form.Controls.Add($btnClose)

$folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog

$btnAddSource.Add_Click({
    if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $path = $folderDialog.SelectedPath
        if (-not $listSources.Items.Contains($path)) {
            [void]$listSources.Items.Add($path)
        }
    }
})

$btnRemoveSource.Add_Click({
    if ($listSources.SelectedIndex -ge 0) {
        $listSources.Items.RemoveAt($listSources.SelectedIndex)
    }
})

$btnClearSources.Add_Click({
    $listSources.Items.Clear()
})

$btnBrowseDestination.Add_Click({
    if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtDestination.Text = $folderDialog.SelectedPath
    }
})

$btnClose.Add_Click({
    $form.Close()
})

$btnRun.Add_Click({
    try {
        if ($listSources.Items.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("Add at least one source folder.")
            return
        }

        if ([string]::IsNullOrWhiteSpace($txtDestination.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Select a destination folder.")
            return
        }

        $destination = $txtDestination.Text.Trim()
        if (-not (Test-Path -LiteralPath $destination)) {
            [System.Windows.Forms.MessageBox]::Show("Destination folder does not exist.")
            return
        }

        $allFiles = New-Object 'System.Collections.Generic.List[System.IO.FileInfo]'
        foreach ($src in $listSources.Items) {
            if (-not (Test-Path -LiteralPath $src)) { continue }

            $items = if ($chkRecurse.Checked) {
                Get-ChildItem -LiteralPath $src -File -Recurse -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -match '(?i)\.jpg$' }
            } else {
                Get-ChildItem -LiteralPath $src -File -ErrorAction SilentlyContinue |
                    Where-Object { $_.Name -match '(?i)\.jpg$' }
            }

            foreach ($f in $items) { $allFiles.Add($f) }
        }

        if ($allFiles.Count -eq 0) {
            [System.Windows.Forms.MessageBox]::Show("No JPG files found in selected source folders.")
            return
        }

        if ($chkClearDest.Checked) {
            Get-ChildItem -LiteralPath $destination -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match '(?i)\.jpg$' } |
                Remove-Item -Force -ErrorAction SilentlyContinue
        }

        $ignoredPattern = '^(0[1-9]|1[0-9]|2[0-4])\.jpg$'
        $preferred = $allFiles | Where-Object { $_.Name -match "(?i)$ignoredPattern" }
        $other = $allFiles | Where-Object { $_.Name -notmatch "(?i)$ignoredPattern" }

        $preferredUnique = Get-UniquePreferredFiles -Files ([System.Collections.Generic.List[System.IO.FileInfo]]$preferred)

        foreach ($file in $preferredUnique) {
            $destPath = Join-Path $destination $file.Name.ToLowerInvariant()
            Copy-Item -LiteralPath $file.FullName -Destination $destPath -Force
        }

        $shuffled = $other | Get-Random -Count $other.Count
        for ($i = 0; $i -lt $shuffled.Count; $i++) {
            $newName = "File{0:D3}.jpg" -f ($i + 1)
            $destPath = Join-Path $destination $newName
            Copy-Item -LiteralPath $shuffled[$i].FullName -Destination $destPath -Force
        }

        $msg = "Done. Copied $($preferredUnique.Count) priority files (01-24) and $($shuffled.Count) shuffled files to:`n$destination"
        [System.Windows.Forms.MessageBox]::Show($msg, "Success")
    }
    catch {
        [System.Windows.Forms.MessageBox]::Show("Error: $($_.Exception.Message)", "Failure")
    }
})

[void]$form.ShowDialog()
