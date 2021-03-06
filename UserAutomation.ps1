### Written and maintained by whisker rebellion

### some dirs and components removed for maintenance of generality.

### Script is divided into 1+3+1 sections: this introductory section followed by the 3 body sections based on the required process for Holter report monitoring, and a cleanup section. The body sections deal with
### the following, including external software


### The introductory section includes bypassing local security which may require signed scripts, may disallow import of modules, or may not allow powershell scripts to run at all, based on settings. 
### The script will then poll a predetermined network file location to check the local version against the latest global version, and update, if necessary. 
### If updated, the user will be prompted to restart the script, at which point the new version will run and delete the old version. Finally, the Press-Tab function is defined, which will send the Tab key
### $numberOfTabs times, traversing whatever menu is in the foreground for the user (instead of the dozens of previous raw .SendKeys({TAB})).



$currentVersion = "0.961"

Write-Host ""
Write-Host ""
Write-Host "UserAutomationScript v$currentVersion"
Write-Host ""
Write-Host ""

#self-updater; put latest script in this dir
$latestScriptDir = ""
$localScriptDir = "C:\Scripts"
$latestVersion = Get-Content "$latestScriptDir\LatestVersion.txt"

#cleaning up old versions' files
if(Test-Path "$localScriptDir\UserAutomationScript.ps1.old"){
	
	Remove-Item "$localScriptDir\UserAutomationScript.ps1.old"

}

if($latestVersion -gt $currentVersion){
	
	try{
		
		Rename-Item "$localScriptDir\UserAutomationScript.ps1" "$localScriptDir\UserAutomationScript.ps1.old" -force
		Copy-Item "$latestScriptDir\UserAutomationScript.ps1" "$localScriptDir\UserAutomationScript.ps1"
		Write-Host "Updated. Script will exit now. Please run the script again."
		exit
	
	}
	
	catch{"Could not fetch latest version. Contact IT for latest version."}
	
}

else{
	
	Write-Host "Your version is up to date!"
	Write-Host ""
	Write-Host ""

}

#Presses tab $numberOfTabs times, allowing users to traverse fields/options in whatever window is in the foreground
Function Press-Tab($numberOfTabs){
	
	$i = 0;
	do{$winShell.SendKeys('{TAB}'); $numberOfTabs--}
	while($i -lt $numberOfTabs)

}

###----------------------------------------------------------------------------
###- 
###----------------------------------------------------------------------------

try{

$rozPath = "C:\Program Files (x86)\" # uses default install directory
$winShell = New-Object -ComObject wscript.shell;
$user = $env:USERNAME
$receivedFilesPath = ""



Write-Host "Press any key to begin"
$waitForInput = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

[string]$patID = Read-Host "What is the Patient ID?"
$fullReceivedPath = $receivedFilesPath + $patID
$workingPath = $fullReceivedPath + "." + $user + ".working"
$isLocked = Test-Path $receivedFilesPath\$patid.*.working


if(Test-Path $fullReceivedPath){
	
	Rename-Item $fullReceivedPath $workingPath

}

elseif($isLocked){
		
	Write-Host "That file is being worked on. Continue? [Y/N]"
	$continueKey = $host.ui.rawui.readkey("NoEcho, IncludeKeyDown")
		
	switch ($continueKey){
		
		"y" {continue}
		"n" {exit}
		default {"Please type Y or N"}
	
	}

}

else{
	
	Write-Host "Error: Cannot find a patient with that ID number."

}

Invoke-Item $rozPath
$fulllocation = $receivedFilesPath + $patID + ".$user" + ".working"
Sleep 1

$winShell.AppActivate("Patient")
$winShell.SendKeys("$patID")
Press-Tab(3)
#SendKeys('~') is Enter key, for reference
$winShell.SendKeys('~') #presses "find" 


Sleep 1
$winShell.SendKeys('~')


Sleep 1
Press-Tab(5)
$winShell.SendKeys('{DOWN}')
					
						
$winShell.SendKeys('{DOWN}') #Lifestar ACT 3
Sleep 1

$winShell.AppActivate("Roz")
Press-Tab(11)
$winShell.SendKeys('{LEFT}')
$winShell.SendKeys("$fulllocation")
Sleep 1
$winShell.SendKeys('~')


Press-Tab(3)
$winShell.SendKeys(' ')
Press-Tab(2)
Sleep 2
$winShell.SendKeys('~')
Sleep 5

}

catch{
	
	Write-Host "There was an error while Rozinnating. Please try to run the script again. Now exiting..."
	sleep 4
	exit

}

###----------------------------------------------------------------------------
###-- Scott Care portion
###----------------------------------------------------------------------------

Write-Host ""
Write-Host ""
Write-Host "Don't forget to manually change the gender of the patient AFTER Rozinn loads the data!!" ## an update to rozinn necessitated this
Write-Host "Press any key to continue to ScottCare Rozinn"
Write-Host ""
Write-Host ""

try{

$waitForInput = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$analystNamePath = "c:\users\$user\Desktop\rozinnAnalystName.txt"

if(Test-Path $analystNamePath){
	
	$userID = Get-Content $analystNamePath

}

else{
	
	$userID = Read-Host "What is your full name and title (e.g. John Smith, CCT)" 
	$userID >> $analystNamePath
	$analystNameFile = Get-Item $analystNamePath
	$analystNameFile.attributes = "Hidden"

}


#Login Section
$rozinnPath = "C:\Program Files (x86)\Rozinn\Rozinn.exe" #Opens Rozinn
Invoke-Item $rozinnPath
Sleep 1
$winShell.SendKeys("holter")
$winShell.SendKeys('{TAB}')
$winShell.SendKeys("holter")
$winShell.SendKeys('{TAB}')
$winShell.SendKeys('~')
Sleep 2
$winShell.AppActivate("Rozinn")
#edit
Press-Tab(32)
$winShell.SendKeys(' ')


Press-Tab(4)
Sleep 1
$winShell.SendKeys('{DOWN}')
$winShell.SendKeys('{DOWN}')
$winShell.SendKeys('{DOWN}')
$winShell.SendKeys('{DOWN}')
$winShell.SendKeys('{DOWN}')

$winShell.SendKeys('~')

Press-Tab(19)

Press-Tab(9)
$winShell.SendKeys(" ")

$winShell.PopUp("Click OK when Rozinn has finished loading the data...", 0, "Is Rozinn Done?")
$winShell.SendKeys("$userID")

Sleep 7 #so as not to instantly ask for report

}

catch{
	
	Write-Host "There was an error in Rozinn. Please try to run the script again. Now exiting..."
	sleep 4
	exit

}


###----------------------------------------------------------------------------
###- Report Importer
###----------------------------------------------------------------------------

Write-Host ""
Write-Host ""
Write-Host "Press any key to continue to Report Importer"
Write-Host ""
Write-Host ""

try{

$waitForInput = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

$pdf = ".PDF"
$pdfPrefix = "C:\Rozinn\STWinOut-"
$computer = "PC1_" + $env:COMPUTERNAME.Substring(4,7) #std computername has PC1- (hyphen) when we want PC1_ underscore
$pdfFile = $pdfPrefix + $computer + "-" + $user + $pdf
$user = $env:USERNAME
[string]$patID = $patID #shouldnt need this type coercion here; can do a test with a .gettype()
$patIDPre = $patID.Substring(0,2)


$repoImport = "C:\Program Files (x86)\ConnectReportImporter\ConnectReportImporterConsole.exe" 

Invoke-Item $repoImport
sleep 3


Press-Tab(10) #Tab to "report file" field
$winShell.SendKeys("$pdfFile") #paste report file in
#after measuring file size, right here we want to select either actex for 24/48 or actafp for 7 day Q drive ...DONE
#4 tabs after changes to get to ACTAFP in dropdown, then 11 more to get to Import
$receivedFilesCount = (gci "$receivedFilesPath\$patid.$user.working").count
$actexThreshold = 310 #the max # of .dat files in 24/48 hour for actex. ~310 < actafp

Press-Tab(4)

if($receivedFilesCount -gt 310){
	
	sleep .5
	$winShell.SendKeys('{DOWN}')
	$winShell.SendKeys('{DOWN}')
	sleep .5

}

Press-Tab(11)
$winShell.SendKeys(" ") #report posted
sleep 7

}

catch{
	
	Write-Host "There was an error in Report Importer. Please try to run the script again. Now exiting..."
	sleep 4
	exit

}

###----------------------------------------------------------------------------
###- Archiving
###----------------------------------------------------------------------------

Write-Host ""
Write-Host ""
#Write-Host "Press any key to archive the PDF, SCP, RES and INI files" ### No longer need to archive these per Joe Clauser, leaving in for legacy

$reportComplete = $false

do{
	
	Write-Host "Did the report complete successfully? [Y/N]"
	$continueKey = $host.ui.rawui.readkey("NoEcho, IncludeKeyDown")
	
	if($continueKey.character -like "y"){
		
		$reportComplete = $true; 
		Write-Host "Proceeding to the archiving process..."; 
		continue;
		
	}
	
	elseif($continueKey.character -like "n"){
		
		$reportComplete = $true; 
		Write-Host "Exiting now. Please restart script to finish the process."; 
		sleep 2; 
		exit
		
	}

}
while(!$reportComplete)


$scp = ".SCP"
$pdfPrefix = "C:\STWinOut-"
$resPrefix = "C:\RozData\" 
$pdfFile = $pdfPrefix + $computer + "-" + $user + $pdf
$actexDir = ""
$archive = $actexDir + $patIDPre
$todaysDateObject = Get-Date
$archivedPrefix = $patID + "-" + $todaysDateObject.year + "." + $todaysDateObject.month + "." + $todaysDateObject.day + "-" + $todaysDateObject.hour + "." + $todaysDateObject.minute + "." + $todaysDateObject.second
$archivedPDFName = $archivedPrefix + $pdf
$archivedSCPName = $archivedPrefix + $scp
$archivedINIRESFiles = $actexDir + "\90-day-archive\Data"

$RozChildItems = gci C:\Roz
$AllLocalSCPFiles = gci C:\Roz\H4\Files
$AllLocalRESINIFiles = gci C:\RozData\ | select 
$LatestSCPFile = $AllLocalSCPFiles | sort LastWriteTime | select -last 1
$pdfFile = $RozChildItems | where{$_.name -like "STWinOut-$computer-$user.pdf"}

Write-Host ""
Write-Host ""
Write-Host "Attempting to copy files..."

try {Write-Host "Copying SCP to $archive\$archivedSCPName..."; Copy-Item "C:\Roz\H4\Files\$LatestSCPFile" $archive\$archivedSCPName -force -erroraction stop}
catch{"Could not copy SCP file"}


try{Write-Host "Copying PDF to $archive\$archivedPDFName..."; Copy-Item "C:\Roz\$pdfFile" $archive\$archivedPDFName -force -erroraction stop}
catch{"Could not copy PDF file"}

Write-Host "Attempting to remove old files..."

try{Write-Host "Removing .DAT files"; Remove-Item "$workingPath\*.dat" -force -erroraction stop}
catch{"Could not remove .DAT files"}

try{Write-Host "Removing .RES files..."; Remove-Item "$resPrefix\*.res" -force -erroraction stop}
catch{"Could not remove .RES files"}

try{Write-Host "Removing .INI files..."; Remove-Item "$resPrefix\*.ini" -force -erroraction stop}
catch{"Could not remove .INI files"}

#if we copied SCP successfully, remove the local version
if(Test-Path "$archive\$archivedSCPName"){
	
	try{Write-Host "Removing local SCP file..."; Remove-Item "C:\Roz\H4\Files\$LatestSCPFile"}
	catch{Write-Host "Did not remove local .SCP file"}

}

Write-Host "Renaming directory from $patid.$user.working back to $patid..."

try{Rename-Item $workingPath $fullReceivedPath -force -erroraction stop}
catch{"Could not rename directory back from .working; if you are done, please change it manually"}

Write-Host ""
Write-Host "Process completed"
sleep 5
exit
