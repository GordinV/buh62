Parameter urLname
Local loRequest, lcUrl, lcFilename, l_last_hash,l_hash
l_last_hash = ''
l_hash = ''

If !File('git_pull.bat')
	Return .F.
Endif

Create Cursor Version(Head m)

* check last version
l_version_file = 'c:\temp\buh60\version'
If File(l_version_file)
	Append Blank
	Append Memo Head From (l_version_file)
	l_hash = Left(Mline(Version.Head, 1),7)
ENDIF

IF FILE('check_for_update.bat')
	WAIT WINDOW 'Loen uuendused' nowait
	! check_for_update.bat
ENDIF


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
