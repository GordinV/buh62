Parameter cWhere

If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif

IF EMPTY(cWhere) AND USED('curTpr')
	cWhere = curTpr.id
ENDIF


l_cursor = IIF(USED('curTpr'),'curTpr','v_library')

IF !USED(l_cursor)
	SELECT 0
	RETURN .f.
ENDIF

TEXT TO lcSql TEXTMERGE noshow
	SELECT * from <<l_cursor>> where id = <<cWhere>> INTO CURSOR tpr_report1
ENDTEXT

&lcSql

select tpr_report1
