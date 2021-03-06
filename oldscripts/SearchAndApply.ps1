<#
ChangeLog:
	- June 5, 2013 : Added -Alignment Parameter to "New-Partition" PS command (Un-Mountable XP Boot Volume Issue)
	- June 6, 2013 : Replaced "/force" with "/mbr" in bootsect.exe commnad.
#>



Function fMain {
#trap {"Error found: $_" | Out-File "x:\SearchAndApply.log"}

	Write-Output "Beginning to search for .WIM file..."
    #Finds the LATEST >1G .WIM File in the root of Logical Disks
	$oWimFiles = Get-WmiObject -Query "SELECT * From Win32_LogicalDisk" | `
        #Commented out on 9/6/2013 DriveType 5 is for CDr/DVDr Types.
		#Where-Object { $_.DriveType -ne "5" } | `
		foreach { Get-ChildItem -Force -Path @($_.DeviceID + "\") } | `
		Where-Object { ($_.FullName -Like "*.wim") -and ($_.Length -ge 1000000000) } | `
		Sort-Object -Descending LastWriteTime

	If ($oWimFiles -eq $null) {Write-Output "No .WIM files found..."; Exit}

    $sQuery = @("SELECT * From Win32_LogicalDisk WHERE DeviceID LIKE " + $oWimFiles[0].PSDrive)
    Write-Output $sQuery
    Get-WmiObject -Query $sQuery
    
    Exit
    
    #Provide Status on what .WIM file will be applied.
	Write-Output @("Image will be applied: " + $oWimFiles[0].FullName)
	Write-Output "Beginning to clean and format disk..."
    
    #Checks if "Local Disk" found is over 100GB.
	$Disk = Get-Disk -Number 0 | Where-Object { $_.Size -gt 100000000000 }
	If ($Disk -eq $null) {Write-Output "Local Disk is not found..."; Exit}

    
    If (Get-WmiObject -Query "SELECT * FROM Win32_LogicalDisk WHERE VolumeName LIKE 'RECOVERY'") {
    #Recovery DOES exist.
        
    }else{
    #Recovery does NOT exist.

    }

    Exit

    
    
	Clear-Disk -Number $Disk.Number -RemoveData -Confirm:$false | Out-Null
	Set-Disk -InputObject $Disk -IsOffline $false | Out-Null
	Initialize-Disk -InputObject $Disk | Out-Null
	Set-Disk -InputObject $Disk -PartitionStyle MBR | Out-Null
	New-Partition $Disk.Number -UseMaximumSize -DriveLetter C -Alignment 1048576 | Out-Null
	Write-Output "Formatting disk..."
	Format-Volume -DriveLetter C -FileSystem NTFS -NewFileSystemLabel OSDISK -Confirm:$false -Force | Out-Null
	Set-Partition $Disk.Number -PartitionNumber 1 -IsActive $True | Out-Null

	Start-Process "x:\windows\system32\cmd.exe" @('/C "imagex /apply "' + `
		$oWimFiles[0].FullName + '" 1 C:"') -Wait -WindowStyle Maximized | Out-Null

	Write-Output @("Image is applied(" + $oWimFiles[0].Name + ":" + $LastExitCode + ")...")

	If (Test-Path "C:\boot.ini") {
		Start-Process "x:\windows\system32\cmd.exe" @('/C "bootsect.exe /nt52 C: /mbr"') -Wait | Out-Null
	} else {
		Start-Process "x:\windows\system32\cmd.exe" @('/C "bcdboot c:\windows"') -Wait | Out-Null
		Start-Process "x:\windows\system32\cmd.exe" @('/C "bcdedit /store C:\Boot\BCD /timeout 0"') -Wait | Out-Null
	}
	
	Write-Output @("Boot sector is prepped... Shutting down in 5 seconds...")
	
	Sleep -Milliseconds 5000
	If (Test-Path "C:\Windows") {
		Start-Process "x:\windows\system32\wpeutil.exe" @('"shutdown"')
	} else {
		Write-Output @("ImageX did not apply image successfully.... Shutting down in 5 seconds...")
		"ImageX did not apply image successfully." | Out-File "x:\SearchAndApplyError.log"
		Exit
	}
}


fMain