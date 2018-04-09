Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0
cursorName = 'v_kassa'

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'ou\kassa'

Wait Window 'test model ' + lcModel  Timeout 1
lsuccess = test_of_selectAsLibs_model()


=SQLDISCONNECT(gnHandle)

Return lsuccess


Function test_of_selectAsLibs_model
	l_cursorName = 'comKassaRemote'
	With oDb
		lcAlias = 'selectAsLibs'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', l_cursorName)

		If 	!lError And Used(l_cursorName) And Reccount(l_cursorName) > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		Dimension aCheckedFields(2)
		aCheckedFields[1] = 'NIMETUS'
		aCheckedFields[2] = 'KOOD'

		lError = check_fields_in_cursor(@aCheckedFields, l_cursorName)

		If !lError
			Return .F.
		Endif


* success
		Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 1
		Use In (l_cursorName)
		Return .T.

	Endwith


Endfunc


Function check_fields_in_cursor(aCheckedFields, tcAlias)
*	Parameters 	aCheckedFields, tcAlias

	lnFields = Afields(laFields,tcAlias)

	For i = 1 To Alen(aCheckedFields)
		lnElement = Ascan(laFields, aCheckedFields[i])

		If lnElement = 0
			Messagebox('test failed, puudub field ' + aCheckedFields[i],0 + 48,'Error')
			lError = .F.
			Exit
		Endif
	Endfor

	Return lError
Endfunc
