# Script Reads a .CSV file and installs listed commands and checks
#	against file or registry to ensure install completed.
#############################################################################
#==========Variables==================================
$oInvocation = (Get-Variable MyInvocation).Value
$sCurrentDirectory = Split-Path $oInvocation.MyCommand.Path
$sLogLocation = "$sCurrentDirectory\InstallScript.log"
$sCVSPath = "$sCurrentDirectory\PoliceUser.csv"
#$ErrorActionPreference = "SilentlyContinue"
#==========Functions==================================
Function fWriteToLog($sUpdateMessage){
	$sDate = Get-Date -Format "MM/dd/yyyy"
    $sTime = Get-Date -Format "hh:mm:ss"
    $sUpdateMessage = "$sDate $sTime : $sUpdateMessage"
    $sUpdateMessage | Write-Host ;$sUpdateMessage | Out-File -FilePath $sLogLocation -Append
}
#==========Main Execution==================================
If (Test-Path $sCVSPath){
	# Reads CVS and skips the 1st line (header row)
	Get-Content $sCVSPath | Select-Object -Skip 1 |
	foreach{
	$aLine = $_.Split(",")
	# Scan .CSV and popuate vars
	$sAppName = ($aLine[0])
	$sAppVersion = ($aLine[1])
	$sCommandProgram = ($aLine[2])
	$sCommandArg = ($aLine[3])
	$sCheckPath = ($aLine[4])
	$sCopyFlag = ($aLine[5])
	$sRegFlag = ($aLine[6])

	If (($sCheckPath -eq "") -or (!(Test-Path $sCheckPath)))
	{
		fWriteToLog "Initiating $sAppName Installation.`r`n"`,
			"With Command: $sCommandProgram $sCommandArg"
		&$sCommandProgram $sCommandArg # Executing Command with Argument
		fWriteToLog "Command completed and returned with a $?."
		If ($sCheckPath -ne ""){
			fWriteToLog "$sCommandProgram install verification will now begin using:`r`n",
				$sCheckPath
			For($i=1; $i -le 31; $i++)
			{
	            If (Test-Path $sCheckPath) #If Checkfile is found For Loop will break
					{fWriteToLog "$sCommandProgram Install is complete and verified.`r`n";break}
	           	fWriteToLog "Delay $i/30 minutes..."
				Start-Sleep -Seconds 60 #Check for completion of install every minute
				If ($i -eq 30){
	           	fWriteToLog "Verification of Install did not complete in the alloted",`
	           		"30 minute time period.  Restarting Computer..."
	           	Restart-Computer}
			}
		} Else {fWriteToLog "No installation verification check was issued for $sAppName."}
	} Else {fWriteToLog "$sAppName is already installed, skipping install."}
	}
}
################Example .CSV Input#########################
<#
Command Name,Version,Command Program,Command Argument,File or Folder Check,Copy Local Flag,Add Install Flag
7-Zip,9.2,msiexec.exe,/i 7z920-x64.msi /qn /l* C:\Windows\Temp\7-ZipInstall.log,C:\Program Files\7-Zip\7z.exe,FALSE,TRUE
Java,7u17,cmd.exe,/c java7u17\install.bat,C:\Program Files\Java\jre7\bin\javaw.exe,FALSE,TRUE
#>
############################################################
