Local lnRekvid

Do Form valirekv To gRekv
If !Empty(gRekv)

	=close_opened_cursors()

	Select comrekvremote
	Locate For Id = gRekv
	Wait Window ' Oodake, k�ivitan '+ Left(Alltrim(comrekvremote.nimetus),40) Nowait
* vahetan rekvid
	oConnect.rekvAndmed()
	oConnect.createMenu('',1)

	Select comrekvremote
	Locate For Id = gRekv

	l_caption = 'Raamatupidamine 7.0 '
	IF type('v_config.app_name') = 'C' 
		l_caption  = v_config.app_name
	endif
	_Screen.Caption = l_caption + ' ' + Alltrim(comrekvremote.nimetus)

	Do open_lib With 1
* refresh toolbar
	If Type('oTools') = 'O'
		oTools.Refresh()
	Endif


	Messagebox('Ok',0,'Vali asutus')
Endif


FUNCTION close_opened_cursors
	IF USED('comOsakondRemote')
		USE IN comOsakondRemote
	ENDIF

ENDFUNC
