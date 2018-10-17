Parameter urLname
Local loRequest, lcUrl, lcFilename, l_last_hash,l_hash
l_last_hash = ''
l_hash = ''

If !Used('config')
	Use config In 0
Endif

If Empty(config.uuEnda) Or !File('git_pull.bat')
	Return .F.
Endif

Wait Window 'Kontrollin uuendused ...' Nowait
If File('check_for_update.bat')
	! /N7 check_for_update.bat
Endif


Create Cursor Version(Head m)

* check last version
l_version_file = 'c:\temp\buh60\version'
If File(l_version_file)
	Append Blank
	Append Memo Head From (l_version_file)
	l_hash = Left(Mline(Version.Head, 1),7)
Endif

* looking for last updates
l_updates_file = 'c:\temp\buh60\updates'
If File(l_updates_file)
	Select 	Version
	Delete All
	Append Blank
	Append Memo Head From (l_updates_file)
	l_last_hash = Left(Mline(Version.Head, 1),7)
Endif

Use In Version

If l_last_hash <> l_hash
* new update is available
	Wait Window 'Kontrollin uuendused ... leidsin uuendus' Timeout 3
	Return .T.
Else
	Wait Window 'Kontrollin uuendused ... puudbub' Nowait
	Return .F.
Endif

Return
