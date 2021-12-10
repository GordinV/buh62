Parameters tnId, is_popup, menu_name
Local lError
Select curMenuRemote
Locate For Id = tnId

If Found() And !Empty(curMenuRemote.Proc)
	If is_popup
		Hide POPUP (menu_name)
	Endif
	lError =Execscript(curMenuRemote.Proc)
	If is_popup
		Deactivate POPUP (menu_name)
		Release Popups (menu_name)
	Endif
ELSE
	IF tnId = 9999 
		WAIT WINDOW 'test menu Ok'
	ELSE	
	Messagebox('Not found')
	ENDIF
	
ENDIF


Return lError
