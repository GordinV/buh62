
Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif

IF EMPTY(cWhere) AND USED('curObjekt')
	cWhere = curObjekt.id
ENDIF


l_cursor = IIF(USED('curObjekt'),'curObjekt','v_library')

IF !USED(l_cursor)
	SELECT 0
	RETURN .f.
ENDIF

TEXT TO lcSql TEXTMERGE noshow
	SELECT * from <<l_cursor>> where id = <<cWhere>> INTO CURSOR objekt_report1
ENDTEXT

&lcSql

select objekt_report1