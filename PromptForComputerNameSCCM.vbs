'Prompt for ComputerName via SCCM/TS TS
Dim strComputerName
 
strComputerName = InputBox("Enter a new machine name for this computer:", "Rename Computer")

SET env = CreateObject("Microsoft.SMS.TSEnvironment") 
env("OSDCOMPUTERNAME") = strComputerName