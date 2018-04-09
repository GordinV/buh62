Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0
cursorName = 'v_eelarve'

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'eelarve\tulude_kassa_taitmine'
Wait Window 'test model ' + lcModel  Timeout 1
lsuccess = test_of_grid_model()

=SQLDISCONNECT(gnHandle)

Return lsuccess

Function test_of_grid_model
	Local cursorName
	cursorName  = 'tmpEelarve'
	is_arhiiv = .f.
	params = null

	With oDb
		Local lcWhere
		lcWhere = "artikkel ilike '%'"
		lcAlias = 'curTuluTaitm'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'is_arhiiv, params', cursorName, lcWhere)

		If 	!lError Or !Used(cursorName)
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 3
			Use In (cursorName)
			Return .T.
		Endif
	Endwith
Endfunc
