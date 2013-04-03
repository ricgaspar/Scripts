$oInvocation = (Get-Variable MyInvocation).Value
$sCurrentDirectory = Split-Path $oInvocation.MyCommand.Path

Function fQueryModem($sQueryString, $sRegExp) {
$oComPort = New-Object System.IO.Ports.SerialPort $sComPortNumber,$sComPortSpeed,None,8,1
$oComPort.Open()
$oComPort.Write("AT")
$oComPort.Write($sQueryString + "`r")
Start-Sleep -m 50
$tVar = $oComPort.ReadExisting()
$tVar = ($tVar -replace "OK","").trim()
$oComPort.Close()

If (!($sRegExp -eq "")) {$tVar -Match $sRegExp|Out-Null; $tVar = $Matches[0]}
return $tVar
}

#AT Commands to pull information from Modems
#"MEID", "+CGSN"			#i.e. "990000780252708"
#"Modem Model", "+CGMM"		#i.e. "MC7750"
#"Phone Number", "+CNUM"	#i.e. "+CNUM: "Line 1","+15514972305",145"
#"SIM", "+ICCID"			#i.e. "ICCID: 89148000000148583496"
#*Commands pulled using AT+CLAC command...

#Grab COMPort number and max ComPort speed
$sComPortNumber = Get-WMIObject Win32_PotsModem | `
	Where-Object {$_.DeviceID -like "USB\VID*" -and $_.Status -like "OK"} | `
	foreach {$_.AttachedTo}
$sComPortSpeed = Get-WMIObject Win32_PotsModem | `
	Where-Object {$_.DeviceID -like "USB\VID*" -and $_.Status -like "OK"} | `
	foreach {$_.MaxBaudRateToSerialPort}

#Populate Variables using fQueryModem Function Call
$sMEID = fQueryModem "+CGSN" "\d{15}"
$sModemModel = fQueryModem "+CGMM" "" #Match Everything
$sPhoneNumber = fQueryModem "+CNUM" "\d{11}"
$sSIM = fQueryModem "+ICCID" "\d{20}"

#Populate TXT file with captured variables
$sDate = Get-Date -Format "MM/dd/yyyy"
$sOutString = "Date: $sDate
Username: $env:username
MEID: $sMEID
Modem Model: $sModemModel
Phone Number: $sPhoneNumber
SIM Number: $sSIM"
$sOutString | Out-File -FilePath "$sCurrentDirectory\ModemInformation.TXT" -Force