# 3ds-nds-save-transfer

Simple Powershell script for copying NDS files between a 3DS SD card and your PC. Requires the ability to run Powershell scripts on your PC.

## Purpose

To assist in managing NDS related data for those who like to emulate on both their PC and homebrewed 3ds.

This script prefers the use of **melonDS** as your PC emulator, as it assumes your saves and ROMs will be in the same folder. It also does not convert `.dsv` save files into `.sav` save files.

## How to Use

Once downloaded, move this script somewhere it can be accessed easily. This might be the root of your SD card, for easy access no matter which device you're using.

On Windows, right click the script and select "Run with Powershell." Follow the on-screen prompts to copy information between your SD card and PC.

## For Your Consideration

When prompted to save any entered file paths to speed up future runs, the script will store the given file path in your local user's environment variables. These can be cleared at any time by selecting option 4 of the script, or manually clearing the environment variables on your own.
