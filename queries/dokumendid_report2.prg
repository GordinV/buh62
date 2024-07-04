Parameter cWhere
l_asutus_id  = 0

IF USED('v_asutus')
l_asutus_id  = v_asutus.id 
ENDIF


If isdigit(alltrim(cWhere))
	l_asutus_id = val(alltrim(cWhere))
ENDIF

IF EMPTY(l_asutus_id)
	MESSAGEBOX('Puudub parameter asutus_id',0+16,'Dokumendid')
	SELECT 0
	RETURN .f.
ENDIF

lError = oDb.readFromModel('libs\libraries\asutused', 'dokumenidid', 'l_asutus_id ', 'dok_report1')

If !lError
	Messagebox('Viga',0+16, 'Dokumendid')
	Set Step On
	SELECT 0
	RETURN .f.
Endif

SELECT dok_report1
