Sub CompareDrivers()

'Starting and Ending Row for Driver Comparision in Template
Dim rowNum As Integer
Dim rowEnd As Integer

'End Row for scanning on Image Under Test Form
Dim scanEnd As Integer

'Row after removing doublespacing
Dim targetDriver As String

'Variable to shade cells Green (4), Red (3), or Yellow (6)
Dim shadingColor As Integer

'Driver Name and Version from Template
Dim driverName As String
Dim driverVersion As String

'Driver Name and Version from Image
Dim driverNameOutput As String
Dim driverVersionOutput As String

'Used to find the character count in a string where there's a period
Dim periodInt As Integer
periodInt = 0

'Selects the image name to test
Dim ImageName As String
Sheets("Instructions").Select
ImageName = Range("F7")

'Starting and Ending Rows on Template
rowNum = 2

'Find end row of template
rowEnd = 2
Sheets(ImageName).Select
Do
    If (Range("A" & (rowEnd + 1))) <> "" Then
        rowEnd = rowEnd + 1
    Else
        Exit Do
    End If
Loop

'Ending Row on Image Under Test Form
scanEnd = 500

'Loop to cycle through all drivers in template
Dim j As Integer 'Dummy Counting Variable
For j = rowNum To rowEnd
    
    'Select the Driver Name and Version from Template
    Sheets(ImageName).Select
    driverName = Range("A" & rowNum)
    driverVersion = Range("B" & rowNum)
    Dim k As Integer 'Dummy Counting Variable
    For k = 1 To 30
        driverName = Trim(Replace(driverName, "  ", " "))
        driverName = Trim(Replace(driverName, "0", ""))
        driverVersion = Trim(Replace(driverVersion, "  ", " "))
        driverVersion = Trim(Replace(driverVersion, "0", ""))
        driverVersion = Trim(Replace(driverVersion, "®", ""))
        
    Next
    
    Sheets("ImageUnderTest").Select
    
    'Loop to cycle through all drivers in PC Viewer
    Dim i As Integer 'Dummy Counting Variable
    For i = 1 To scanEnd
        
        'Looks for driver name from Template in Image Under Test
        targetDriver = Range("A" & i)
        Dim l As Integer 'Dummy Counting Variable
        For l = 1 To 30
            targetDriver = Trim(Replace(targetDriver, "  ", " "))
            targetDriver = Trim(Replace(targetDriver, "0", ""))
            driverVersion = Trim(Replace(targetDriver, "®", ""))
        Next
        If InStr(targetDriver, driverName) Then
            
            driverNameOutput = driverName
            
            'Checks driver version from Template
            If InStr(targetDriver, driverVersion) Then
                driverVersionOutput = driverVersion
                shadingColor = 4    'Shade Green
            Else
                shadingColor = 3    'Shade Red
                'Looks for period to search for driver version #
                'Used to check driver version in image
                If InStr(targetDriver, ".") Then
                    periodInt = InStr(targetDriver, ".")
                    driverVersionOutput = Trim(Mid(targetDriver, periodInt - 2, 15))
                Else
                    driverVersionOutput = "Could not find version"
                End If
                
            End If
            Exit For
        End If
        
    Next i
    
    'Sets driver version as Missing Driver if driver is not found
    If driverNameOutput = "" Then
        driverNameOutput = driverName
        driverVersionOutput = "MISSING DRIVER"
        shadingColor = 6    'Shade Yellow
    End If
    
    'Writes to Output sheet
    Sheets("Output").Select
    Range("A" & rowNum) = driverNameOutput
    Range("B" & rowNum) = driverVersion
    Range("C" & rowNum) = driverVersionOutput
    Range("A" & rowNum).Select
    Selection.Interior.ColorIndex = shadingColor
    Range("B" & rowNum).Select
    Selection.Interior.ColorIndex = shadingColor
    Range("C" & rowNum).Select
    Selection.Interior.ColorIndex = shadingColor

    'Reset Variables
    driverName = ""
    driverVersion = ""
    driverNameOutput = ""
    driverVersionOutput = ""
    shadingColor = 0
    periodInt = 0
    
    rowNum = rowNum + 1

Next j

End Sub