Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0
cursorName = 'v_palk_jaak'

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'palk\palk_jaak'

Wait Window 'test model ' + lcModel  Timeout 1


lsuccess = test_of_grid_model()


=SQLDISCONNECT(gnHandle)

Return lsuccess


Function test_of_grid_model
	Local cursorName
	Dimension aCheckedFields(10)
	aCheckedFields[2] = 'NIMETUS'
	aCheckedFields[3] = 'KUU'
	aCheckedFields[4] = 'AASTA'
	aCheckedFields[5] = 'ARVESTATUD'
	aCheckedFields[6] = 'KINNI'
	aCheckedFields[7] = 'TULUMAKS'
	aCheckedFields[8] = 'SOTSMAKS'
	aCheckedFields[9] = 'JAAK'
	aCheckedFields[10] = 'MVT'

	cursorName  = 'tmpPalkJaak'

	Local lcWhere
	tnKuu1 = MONTH(Date(2018,01,01))
	tnKuu2 = MONTH(Date())

TEXT TO lcWhere NOSHOW textmerge
	kuu >= ?tnKuu1 and kuu <= ?tnKuu2

ENDTEXT

	lcSubTotals = " sum (JAAK) OVER()  as JAAK_kokku ,  count(id) over() as read_kokku"

* parameters
	lError = oDb.readFromModel(lcModel, 'curPalkJaak', 'gRekv, guserid', cursorName, lcWhere, lcSubTotals)

	If 	!lError Or !Used(cursorName)
		Messagebox('test failed',0 + 48,'Error')
		Set Step On
		Return .F.
	Endif

	lError = check_fields_in_cursor(@aCheckedFields, cursorName)

	If 	!lError
		Messagebox('test failed, puuduvad vajaliku andmed',0 + 48,'Error')
		Return .F.
	Endif

* success
	If lError
		Wait Window 'test model ' + lcModel + ', curPalkOper -> passed' Timeout 3
		Use In (cursorName)
	Endif
	Return lError
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
