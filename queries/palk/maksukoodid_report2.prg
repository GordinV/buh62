Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif

IF EMPTY(cWhere) AND USED('curMaksukoodid')
	cWhere = curMaksukoodid.id
ENDIF


l_cursor = IIF(USED('curMaksukoodid'),'curMaksukoodid','v_maksukood')

IF !USED(l_cursor)
	SELECT 0
	RETURN .f.
ENDIF

TEXT TO lcSql TEXTMERGE noshow
	SELECT * from <<l_cursor>> where id = <<cWhere>> INTO CURSOR maksukoodid_report1
ENDTEXT

&lcSql

select maksukoodid_report1
