Parameter cWhere
If Vartype(cWhere) = 'C'
	tnId = Val(Alltrim(cWhere))
Else
	tnId = cWhere
ENDIF


If Empty (tnId)
	Return .F.
Endif
If !Used('v_pv_kaart')
	lError = oDb.readFromModel('libs\libraries\pv_kaart', 'row', 'tnId, guserid', 'v_pv_kaart')
ENDIF

Select * From v_pv_kaart Into Cursor pvkaart_report1

Select pvkaart_report1
