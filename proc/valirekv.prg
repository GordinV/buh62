Local lnRekvid

Do Form valirekv To gRekv
If !Empty(gRekv)
	Select comrekvremote
	Locate For Id = gRekv
	Wait Window ' Oodake, käivitan '+ Left(Alltrim(comrekvremote.nimetus),40) Nowait
* vahetan rekvid
	oConnect.rekvAndmed()
	Select comrekvremote
	Locate For Id = gRekv
	_Screen.Caption = 'Raamatupidamine 6.2 ' + Alltrim(comrekvremote.nimetus)


	Do open_lib With 1
	Messagebox('Ok',0,'Vali asutus')
Endif
