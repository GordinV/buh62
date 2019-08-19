Local lnRekvid

Do Form valirekv To gRekv
If !Empty(gRekv)

	=close_opened_cursors()

	Select comrekvremote
	Locate For Id = gRekv
	Wait Window ' Oodake, käivitan '+ Left(Alltrim(comrekvremote.nimetus),40) Nowait
* vahetan rekvid
	oConnect.rekvAndmed()
	oConnect.createMenu('',1)

	Select comrekvremote
	Locate For Id = gRekv
	_Screen.Caption = 'Raamatupidamine 6.2 ' + Alltrim(comrekvremote.nimetus)

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
