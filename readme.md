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

- Local folder with .jpg files saved from various sources
- USB drive for output
- Powershell

## Required output:

- Randomize the order of files.
- Filenames must be new.
- This script can be run on demand.
- Output is saved to the root folder of the USB drive. The number of files does not change.

# Goal:

Use AI to generate this code. Keep track of prompts and responses in `ailog.txt`
