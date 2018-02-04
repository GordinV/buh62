Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'libs\libraries\ladu_jaak'

Wait Window 'test model ' + lcModel  Timeout 1
lsuccess = test_of_grid_model()

If lsuccess
	lsuccess = test_of_selectAsLibs_model()
Endif

If lsuccess
	lsuccess = test_of_anuluus()
Endif

If lsuccess
	lsuccess = test_of_recalcLaduJaak()
Endif

=SQLDISCONNECT(gnHandle)

Return lsuccess


Function test_of_recalcLaduJaak

	With oDb
* parameters

		lcAlias = 'recalcLaduJaak'
		tnNomId = 0
		tnArveId = 0
		Select curLaduJaak
		If Reccount('curLaduJaak') > 0
			Go Top
			tnNomId = curLaduJaak.nomid
		Endif

		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv,tnNomId,tnArveId', 'tmpRecalcLaduJaak')

		If 	!lError
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

* success
		Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 1
		Use In tmpRecalcLaduJaak
		Return .T.

	Endwith


Endfunc

Function test_of_anuluus

	With oDb
* parameters
		lcAlias = 'Analuus'
		Select curLaduJaak

		If Reccount('curLaduJaak') > 0
			Go Top
			tcKood = curLaduJaak.kood
			tcHind = curLaduJaak.hind
		Else
			tcKood = ''
			tcHind = 0
		Endif

		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv,tcKood,tcHind', 'sqlAnaluus')

		If 	!lError And !Used('sqlAnaluus')
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

* success
		Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 1
		Use In sqlAnaluus
		Return .T.

	Endwith


Endfunc



Function test_of_selectAsLibs_model

	With oDb
		lcAlias = 'selectAsLibs'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', 'comnomRemote')

		If 	!lError And Used('comnomRemote')
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

* success
		Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 1
		Use In comnomRemote
		Return .T.

	Endwith


Endfunc


Function test_of_grid_model
	Dimension aCheckedFields(6)
	aCheckedFields[1] = 'GRUPP'
	aCheckedFields[1] = 'NIMETUS'
	aCheckedFields[1] = 'HIND'
	aCheckedFields[1] = 'JAAK'
	aCheckedFields[1] = 'SUMMA'
	aCheckedFields[1] = 'KOGUS'

	With oDb
		Local lcWhere
		lcWhere = "kood ilike 'test%'"
		lcSubTotals = " sum (hind * jaak) OVER()  as summa, sum(jaak) over() as kogus"
		lcAlias = 'curLaduJaak'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', lcAlias, lcWhere, lcSubTotals)

		If 	!lError Or !Used(lcAlias)
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		lnFields = Afields(laFields,lcAlias)

		For i = 1 To Alen(aCheckedFields)
			lnElement = Ascan(laFields, aCheckedFields[i])

			If lnElement = 0
				Messagebox('test failed, puudub field ' + aCheckedFields[i],0 + 48,'Error')
				lError = .F.
				Exit
			Endif
		Endfor

		If lError
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 3
		ENDIF
		Return  lError
	Endwith
Endfunc
