Set Classlib To classes\Classlib

*LOCAL oDb, gnHandle
gVersia = 'PG'
oDb = Createobject('db')

gRekv = 1
guserid = 1
tnId = 0
cursorName = 'v_library'

gnHandle = SQLConnect('localPg', 'vlad','123')
If gnHandle < 0
	Messagebox('Connection error',0+48,'Error')
	Return .T.
Endif

lcModel = 'eelarve\eel_config'

Wait Window 'test model ' + lcModel  Timeout 1

lsuccess = test_of_kassa_kontod_model()


If lsuccess
	lsuccess = test_of_kassa_kulud_model()
Endif

If lsuccess
	lsuccess = test_of_kulu_kontod_model()
Endif

If lsuccess
	lsuccess = test_of_kassa_tulud_model()
Endif

If lsuccess
	lsuccess = test_of_tulu_kontod_model()
Endif

If lsuccess
	lsuccess = test_of_row_validate_model()
Endif

If lsuccess
	lsuccess = test_of_row_save_model()
Endif




=SQLDISCONNECT(gnHandle)

Return lsuccess


Function test_of_tulu_kontod_model
	l_cursorName = 'v_tulu_kontod'
	With oDb
* parameters
		lError = oDb.readFromModel(lcModel, 'tulu_kontod', 'gRekv, guserid', l_cursorName)
		
		

		If 	!lError And Used(l_cursorName) And Reccount(l_cursorName) > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif
		SELECT (l_cursorName)
		APPEND BLANK
		replace kood WITH '10', nimetus WITH 'tulu_kontod', library WITH 'KASSAKONTOD' 

* success
		Wait Window 'test model ' + lcModel + ', tulu_kontod -> passed' Timeout 1
		Return .T.

	Endwith
Endfunc


Function test_of_kassa_tulud_model
	l_cursorName = 'v_kassa_tulud'
	With oDb
* parameters
		lError = oDb.readFromModel(lcModel, 'kassa_tulud', 'gRekv, guserid', l_cursorName)

		If 	!lError And Used(l_cursorName) And Reccount(l_cursorName) > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		ENDIF
		
		SELECT (l_cursorName)
		APPEND BLANK
		replace kood WITH '20', nimetus WITH 'tulu_kontod', library WITH 'KASSATULUD' 


* success
		Wait Window 'test model ' + lcModel + ', kassa_tulud -> passed' Timeout 1
		Return .T.

	Endwith
Endfunc


Function test_of_kulu_kontod_model
	l_cursorName = 'v_kulu_kontod'
	With oDb
* parameters
		lError = oDb.readFromModel(lcModel, 'kulu_kontod', 'gRekv, guserid', l_cursorName)

		If 	!lError And Used(l_cursorName) And Reccount(l_cursorName) > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		SELECT (l_cursorName)
		APPEND BLANK
		replace kood WITH '30', nimetus WITH 'kulu_kontod', library WITH 'KULUKONTOD' 


* success
		Wait Window 'test model ' + lcModel + ', kulu_kontod -> passed' Timeout 1
		Return .T.

	Endwith
Endfunc


Function test_of_kassa_kulud_model
	l_cursorName = 'v_kassa_kulud'
	With oDb
* parameters
		lError = oDb.readFromModel(lcModel, 'kassa_kulud', 'gRekv, guserid', l_cursorName)

		If 	!lError And Used(l_cursorName) And Reccount(l_cursorName) > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif


		SELECT (l_cursorName)
		APPEND BLANK
		replace kood WITH '40', nimetus WITH 'kassa_kulud', library WITH 'KASSAKULUD' 



* success
		Wait Window 'test model ' + lcModel + ', kassa_kulud -> passed' Timeout 1
		Return .T.

	Endwith
Endfunc



Function test_of_kassa_kontod_model
	l_cursorName = 'v_kassa_kontod'
	With oDb
* parameters
		lError = oDb.readFromModel(lcModel, 'kassa_kontod', 'gRekv, guserid', l_cursorName)

		If 	!lError And Used(l_cursorName) And Reccount(l_cursorName) > 0
			Messagebox('test failed',0 + 48,'Error')
			Return .F.
		Endif

		SELECT (l_cursorName)
		APPEND BLANK
		replace kood WITH '50', nimetus WITH 'kassa_kontod', library WITH 'KASSAKONTOD' 


* success
		Wait Window 'test model ' + lcModel + ', kassa_kontod -> passed' Timeout 1
		Return .T.

	Endwith
Endfunc


Function test_of_row_validate_model()
	lcAlias = 'validate'
	cursorName = 'v_library'
	Select v_model
	Locate For !Empty(Validate)

	If Eof()
* not found
		Return .T.
	Endif

	lcValidate = Alltrim(v_model.Validate)


	lcNotValidFields = oDb.Validate(lcValidate, cursorName)
* expect LIBRARY

	If Type('lcNotValidFields') = 'C'
		Select (cursorName)
		Replace Id With 0, rekvid With gRekv, kood With '__test' + Left(Alltrim(Str(Rand() * 10000)),10),;
			nimetus With 'vfp test',;
			library With 'ALLIKAD'
	Endif

	lcNotValidFields = oDb.Validate(lcValidate, cursorName)
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


Function test_of_row_save_model
	l_kassa_kontod = ''
	l_kassa_kulud = ''
	l_kulu_kontod = ''
	l_kassa_tulud = ''
	l_tulu_kontod = ''
	With oDb
		lcAlias = 'saveDoc'
* parameters
		SELECT v_kassa_kontod
		
		lcJson = '{"id":1,"data":'+ oDb.getJson() + '}'
		l_kassa_kontod = oDb.getJson()

		SELECT v_kassa_kulud
		l_kassa_kulud = oDb.getJson()
		
		SELECT v_kulu_kontod
		l_kulu_kontod = oDb.getJson()
		
		SELECT v_kassa_tulud
		l_kassa_tulud = oDb.getJson()	
		
		SELECT v_tulu_kontod
		l_tulu_kontod = oDb.getJson()		
		
		TEXT TO lcJson TEXTMERGE noshow
			{"id":1,"kassaKontod":[<<l_kassa_kontod>>],"kassaKulud":[<<l_kassa_kulud>>],"kuluKontod":[<<l_kulu_kontod>>],"kassaTulud":[<<l_kassa_tulud>>],"tuluKontod":[<<l_tulu_kontod>>]}	
		ENDTEXT
				
		lError = oDb.readFromModel(lcModel, 'saveDoc', 'lcJson,gUserid,gRekv', 'v_eel_config_id')

		If 	!lError And Used('v_eel_config_id') And Reccount('v_eel_config_id') > 0 AND v_eel_config_id.id > 0
			Messagebox('test failed',0 + 48,'Error')
			Set Step On
			Return .F.
		Else
* success
			Wait Window 'test model ' + lcModel + ', saveDoc new -> passed' Timeout 1
			tnId = 1
			Return .T.
		Endif


	Endwith
ENDFUNC

