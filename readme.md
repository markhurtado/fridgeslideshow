# Mark's fridge slideshow project

This is a side project to generate a simple script to automate some file management tasks.

## Problem:

Slideshow feature on fridge is not randomized. Photos play in the filename order every time.

Photos come from various sources and have different naming conventions.

File transfer with USB is cumbersome.

## Solution:

Take photo folder, randomize file names, save to the root of a USB drive in the new order.

TODO: Set up OneDrive integration to run from any computer without files saved locally.
TODO: figure out way to transfer to fridge besides USB.

## Pre-reqs:

- Folders with .jpg files saved from various sources
- USB drive for output
- PowerShell

## How to use:

1. Run `shufflefiles.ps1` in PowerShell
2. Click "Add folder" to select one or more source folders containing JPG files
3. Use "Remove selected" or "Clear all" to manage your source list
4. Click "Browse" to select your USB drive (destination folder)
5. Optionally check "Include subfolders" to search nested directories
6. Optionally check "Delete existing JPG files in destination first" to clear the USB before writing
7. Click "Shuffle and copy to USB" to process and transfer your files
8. Files named 01.jpg through 24.jpg play first in order; all others are randomized and renamed

## Output behavior:

- Randomizes the order of files
- Renames files to randomized sequence (File001.jpg, File002.jpg, etc.)
- Can be run on demand
- Output is saved to the root folder of the USB drive
- File count does not change
- All files have lowercase .jpg extension
- Files named "01.jpg" through "24.jpg" are preserved with original names and play first
