Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0
constKonto = 'KONTO'
constTegev = 'TEGEV'
constAllikas = 'ALLIKAS'
CONSTRahavoog = 'RV'
constArtikkel = 'ART'

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'libs\libraries\nomenclature'

Wait Window 'test model ' + lcModel  Timeout 1
lsuccess = test_of_grid_model()
If lsuccess
	lsuccess = test_of_row_new_model()
Endif
If lsuccess
	lsuccess = test_of_row_validate_model()
Endif
If lsuccess
	lsuccess = test_of_row_save_model()
Endif

If lsuccess
	lsuccess = test_of_row_model()
Endif

If lsuccess
	lsuccess = test_of_selectAsLibs_model()
Endif

If lsuccess
	lsuccess = test_of_row_delete_model()
Endif


=SQLDISCONNECT(gnHandle)

Return lsuccess

Function test_of_selectAsLibs_model

	With oDb
		lcAlias = 'selectAsLibs'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', 'comnomRemote')

		If 	!lError And Used('comnomRemote') And Reccount('comnomRemote') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

* kas uut Id in list
		Select comnomRemote
		Locate For Id = tnId

		If !FOUND() Then
			Messagebox('test failed, id not found',0 + 48,'Error')
			Return .F.
		Endif
* kas klassifikaatorid on ?

		If 	ALLTRIM(comnomRemote.konto) <> ALLTRIM(constKonto) Or ALLTRIM(comnomRemote.tegev) <> ALLTRIM(constTegev) Or; 
			ALLTRIM(comnomRemote.allikas) <> ALLTRIM(constAllikas) Or ALLTRIM(comnomRemote.rahavoog) <> ALLTRIM(CONSTRahavoog) Or ;
				ALLTRIM(comnomRemote.artikkel) <> ALLTRIM(constArtikkel)

			Messagebox('test failed, klassiflibs kehtitu',0 + 48,'Error')
			Return .F.
		Endif


* success
		Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 1
		Use In comnomRemote
		Return .T.

	Endwith


Endfunc


Function test_of_row_validate_model()
	lcAlias = 'validate'
	Select v_model
	Locate For !Empty(Validate)

	If Eof()
* not found
		Return .T.
	Endif

	lcValidate = Alltrim(v_model.Validate)


	lcNotValidFields = oDb.Validate(lcValidate, 'v_nomenklatuur')
* expect LIBRARY

	If Type('lcNotValidFields') = 'C'
		Replace Id With 0, rekvid With gRekv, kood With '__test' + Left(Alltrim(Str(Rand() * 10000)),10),;
			nimetus With 'vfp test', dok With 'TEST',;
			konto With constKonto,;
			tegev With constTegev,;
			allikas With constAllikas,;
			rahavoog With CONSTRahavoog,;
			artikkel With constArtikkel ;
		In v_nomenklatuur
	Endif

	lcNotValidFields = oDb.Validate(lcValidate, 'v_nomenklatuur')
* expect empty
	If Empty(lcNotValidFields)
		Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' validate -> passed' Timeout 1
		Return .T.
	Else
		Messagebox('test failed',0 + 48,'Error')
		Set Step On
		Return .F.

	Endif

Endfunc


Function test_of_row_delete_model

	With oDb
		lcAlias = 'deleteDoc'
* parameters

		lError = oDb.readFromModel(lcModel, lcAlias, 'gUserid,tnId','result')

		If 	!lError Or !Used('result') Or !Isnull(result.error_code)
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' delete -> passed' Timeout 1
			Select result
			Return .T.
		Endif


	Endwith


Function test_of_row_save_model

	With oDb
		lcAlias = 'saveDoc'
* parameters
* cursor v_nomenklatuur -> json
		Select v_nomenklatuur
		lcJson = '{"id":' + Alltrim(Str(v_nomenklatuur.Id)) + ',"data":'+ oDb.getJson() + '}'
		lError = oDb.readFromModel(lcModel, lcAlias, 'lcJson,gUserid,gRekv', 'v_nomenklatuur')

		If 	!lError And Used('v_nomenklatuur') And Reccount('v_nomenklatuur') > 0
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + 'new -> passed' Timeout 1
			Select v_nomenklatuur
			tnId = v_nomenklatuur.Id
			Return .T.
		Endif


	Endwith



Function test_of_row_new_model
	tnId = 0

	With oDb
		lcAlias = 'row'
* parameters
*!*			Create Cursor v_nomenklatuur (Id Int, kood c(20) Null, nimetus c(254) Null, dok c(20) Null, muud m Null, rekvid Int Null, uhik c(20) Null, ;
*!*				hind N(14,2), ulehind N(14,4), kogus N(14,4), Status Int, konto c(20), tunnus c(20), projekt c(20), tegev c(20), allikas c(20), artikkel c(20),;
*!*				rahavoog c(20))

		lError = oDb.readFromModel(lcModel, 'row', 'tnId, guserid', 'v_nomenklatuur')
		If !lError
			Return .F.
		Endif

		If 	!lError Or !Used('v_nomenklatuur') Or Reccount('v_nomenklatuur') = 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + 'new -> passed' Timeout 1
			Return .T.
		Endif


	Endwith


Function test_of_row_model

	With oDb
		lcAlias = 'row'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'tnId, guserid', 'v_nomenklatuur')

		If 	!lError And Used('v_nomenklatuur') And Reccount('v_nomenklatuur') > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 1
*		USE IN v_Tunnus
			Return .T.
		Endif


	Endwith


Endfunc

Function test_of_grid_model
	With oDb
		Local lcWhere
		lcWhere = "kood ilike 'test%'"
		lcAlias = 'curNomenklatuur'
* parameters
		lError = oDb.readFromModel(lcModel, lcAlias, 'gRekv, guserid', 'tmpNom', lcWhere)

		If 	!lError Or !Used('tmpNom')
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', ' + lcAlias + ' -> passed' Timeout 3
			Use In tmpNom
			Return .T.
		Endif
	Endwith
Endfunc
