Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif

IF EMPTY(cWhere) AND USED('curTegev')
	cWhere = curTegev.id
ENDIF


l_cursor = IIF(USED('curTegev'),'curTegev','v_library')

IF !USED(l_cursor)
	SELECT 0
	RETURN .f.
ENDIF

TEXT TO lcSql TEXTMERGE noshow
	SELECT * from <<l_cursor>> where id = <<cWhere>> INTO CURSOR tegev_report1
ENDTEXT

&lcSql

select tegev_report1
