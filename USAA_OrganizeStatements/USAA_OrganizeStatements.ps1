############################################################
# Project : Organize downloaded USAA PDFs into a folder structure
# Developer : Daniel J Shanklin
# PowerShell code taken from: Thiyagu S (dotnet-helpers.com)
# Version: 1.2.4
# 
# Instructions:
# 1.) Download this script to a new folder on your PC
# 2.) Double-click the downloaded PowerShell script to automatically create the folders "USAA Inbox", "USAA Organized", and "USAA Inbox Duplicates"
# 3.) Open https://www.usaa.com/inet/ent_edde/ViewMyDocuments/?0&wa_ref=pri_global_tools_addlservices_viewdocs
# 4.) Click "Download" and choose "Check All", then scroll down and click Download
# 5.) Save all PDFs to the "USAA Inbox" folder created in step 2 above
# 6.) Re-run this powershell script. All files in USAA Inbox will be either moved to "USAA Organized" or "USAA Inbox Duplicates".
# 7.) Files in "USAA Organized" will be organized into subfolders based on the type of PDF and the account number.
############################################################

# If set to 1, then don't move any files, just output
# $DebugMode = 0
$DebugMode = 0

$Instrux = '------------------------------------------------------------
Organize downloaded USAA PDFs into a folder structure
------------------------------------------------------------

Instructions:
1.) Download this script to a new folder on your PC
2.) Double-click the downloaded PowerShell script to automatically create the folders "USAA Inbox", "USAA Organized", and "USAA Inbox Duplicates"
3.) Open https://www.usaa.com/inet/ent_edde/ViewMyDocuments/?0&wa_ref=pri_global_tools_addlservices_viewdocs
4.) Click "Download" and choose "Check All", then scroll down and click Download
5.) Save all PDFs to the "USAA Inbox" folder created in step 2 above
6.) Re-run this powershell script. All files in USAA Inbox will be either moved to "USAA Organized" or "USAA Inbox Duplicates".
7.) Files in "USAA Organized" will be organized into subfolders based on the type of PDF and the account number.

--------------------------------------

'

Write-Host $Instrux

# Establish folder names
[string]$dir = Get-Location
$dt = (get-date).ToString('yyyy-MM-dd HHmmss')
$rootPath = $dir
$srcPath = $rootPath + '/USAA Inbox'
$dstPath = $rootPath + '/USAA Organized'
$dstPathDupes = $rootPath + '/USAA Inbox Duplicates/' + $dt
$dstPathNoDocType = $rootPath + '/USAA Inbox - No Valid Doc Type/' + $dt

# Output folder names
Write-Host 'root path: ' $rootPath

# Create Source Folder
if (Test-Path $srcPath) {

} else {
	New-Item $srcPath -ItemType Directory | out-null
	Write-Host 'source path did not exist... created!'
}
Write-Host 'source path: ' $srcPath

# Create Destination Folder
if (Test-Path $dstPath) {

} else {
	New-Item $dstPath -ItemType Directory | out-null
	Write-Host 'destination path did not exist... created!'
}
Write-Host 'destination path: ' $dstPath

# Set up doc types. The third column = 1 if the filename has an account number at the end and third column = 0 if filename has not account number
[System.Collections.ArrayList]$docTypes = @()
$docTypes += ,@('_BANK_', 'Bank', 1)
$docTypes += ,@('_IMCO_', 'Investments', 1)
$docTypes += ,@('_PC_auto', 'Auto', 0)
$docTypes += ,@('_umbrella', 'Umbrella Insurance', 0)
$docTypes += ,@('_PC_renters', 'Renters Insurance', 0)
$docTypes += ,@('_PC_homeowner', 'Homeowners Insurance', 0)
$docTypes += ,@('_LIFE_', 'Life Insurance', 0)
$docTypes += ,@('_pc_statement_recurring_', 'Policy Bills', 0)
$docTypes += ,@('_PC_persnl_art', 'Valuable Personal Property', 0)
$docTypes += ,@('_wire_transfer_', 'Wire Tranfers', 0)
$docTypes += ,@('_daddisclosure', 'Deposit Disclosures', 0)
 
#Get all the child file list with source folder
$fileList = Get-ChildItem -Path $srcPath -Force -Recurse

#loop the source folder files to find the match
foreach ($file in $fileList)
{

	Write-Host '----------- BEGIN FILE PROCESSING -----------'
	Write-Host 'Source File: ' $file.Name
	
	#checking the match with filterListsWithAcctNumber
	foreach($docType in $docTypes) {
		
		$splitFileName = $file.BaseName 
		$search = '*' + $docType[0] + '*'
		if ($docType[2] -eq 1) {
			[bool]$HasAccountNumber = 1
		} else {
			[bool]$HasAccountNumber = 0
		}

		if ($splitFileName -like $search) {
			$fileName = $file.Name
			$year = $fileName.Substring(0,4)
			$FileExtension = $fileName.Substring($fileName.LastIndexOf('.')+1, $fileName.Length - $fileName.LastIndexOf('.') - 1)
			if($HasAccountNumber) {
				$account = $fileName.Substring($fileName.LastIndexOf('_')+1, $fileName.Length - $fileName.LastIndexOf('_') - 1 - $FileExtension.Length - 1)
				$dstPath2 = $dstPath + '/' + $year + '/' + $docType[1] + '/' + $account
			} else {
				$dstPath2 = $dstPath + '/' + $year + '/' + $docType[1]
			}
			

			Write-Host 'Match found!'
			Write-Host '   Match:            ' $docType[0]
			Write-Host '   Category:         ' $docType[1]
			Write-Host '   Year:             ' $year
			Write-Host '   File Extension:   ' $FileExtension
			if($HasAccountNumber) {
				Write-Host '   Account:          ' $account
			} else {
				Write-Host '   Account:          null'
			}
			Write-Host '   Destination Path: ' $dstPath2
			
			# Create New Path
			Write-Host 'Creating Target Directory:'
			if (Test-Path $dstPath2) {
				Write-Host '   Directory already exists: ' $dstPath2
			} else {
				New-Item $dstPath2 -ItemType Directory | out-null
				Write-Host '   Directory created: ' $dstPath2
			}
			$dstPathWithFilename = $dstPath2 + '/' + $($file.Name)

			# Move file
			Write-Host 'Moving file:'
			if (Test-Path $dstPath2) {
				if (Test-Path $dstPathWithFilename) {
					# If the file already exists in Organized, move to the Dupes folder
					if(-Not $DebugMode) {
						# Create Destination Folder for duplicates
						if (Test-Path $dstPathDupes) {

						} else {
							New-Item $dstPathDupes -ItemType Directory | out-null
							Write-Host 'destination path for duplicates did not exist... created!'
						}
						Move-Item -Path $($file.FullName) -Destination $dstPathDupes
					}
					Write-Host '   Already exists in USAA Organized folder... ' $file.Name ' moved to ' $dstPathDupes
				} else {
					# If the file isn't already in the Organized folder, move it there
					if(-Not $DebugMode) {
						Move-Item -Path $($file.FullName) -Destination $dstPath2
					}
					Write-Host '   ' $file.Name  ' moved to ' $dstPath2
				}
			} else {
				Write-Host '   Error 13: Could not move file because new directory does not exist ' $docType[0] ': ' $splitFileName
			}
			
		}
	}
	
	# If file had no valid doc type, move to that folder
	if(Test-Path $file.FullName) {
		# Create Destination Folder for no valid doc type
		if (Test-Path $dstPathNoDocType) {

		} else {
			New-Item $dstPathNoDocType -ItemType Directory | out-null
			Write-Host 'destination path for no valid doc types did not exist... created!'
		}
		
		Write-Host '   Doc type not found.  Moved to ' $dstPathNoDocType
		Move-Item -Path $($file.FullName) -Destination $dstPathNoDocType
	}
	
	Write-Host '-----------  END FILE PROCESSING  -----------'
}

$strEnd = '--------------------------------------

Done! Be sure to add USAA PDFs to the "USAA Inbox" folder in order to sort them, and then re-run this script.

PDFs will be moved to "USAA Organized", "USAA Inbox Duplicates", or "USAA Inbox - No Valid Doc Type"

--------------------------------------'

Write-Host $strEnd
