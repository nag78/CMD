On Error Resume Next
FullName = WScript.Arguments(0)

With CreateObject("ADODB.Stream")
    .Type = 2
    .Charset = "windows-1251"
    .Open
    .LoadFromFile FullName
    Text = .ReadText()
    .Close

    .Charset = "cp866"
    .Open
    .WriteText (Text)
    .SaveToFile FullName, 2
    .Close
End with