Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif

l_cursor = 'curEelarve'
l_local_cursor = 'v_eelarve'
l_output_cursor = 'eelarve_report1'

IF EMPTY(cWhere) AND USED(l_cursor)
	cWhere = EVALUATE(l_cursor + '.id')
ENDIF

l_cursor = IIF(USED(l_cursor),l_cursor,l_local_cursor)

IF !USED(l_cursor)
	SELECT 0
	RETURN .f.
ENDIF

TEXT TO lcSql TEXTMERGE noshow
	SELECT * from <<l_cursor>> where id = <<cWhere>> INTO CURSOR <<l_output_cursor>>
ENDTEXT

&lcSql

SELECT(l_output_cursor)