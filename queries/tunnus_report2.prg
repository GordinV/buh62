Parameter cWhere

If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif

IF EMPTY(cWhere) AND USED('curTunnus')
	cWhere = curTunnus.id
ENDIF


l_cursor = IIF(USED('curTunnus'),'curTunnus','v_library')

IF !USED(l_cursor)
	SELECT 0
	RETURN .f.
ENDIF

TEXT TO lcSql TEXTMERGE noshow
	SELECT * from <<l_cursor>> where id = <<cWhere>> INTO CURSOR tunnus_report1
ENDTEXT

&lcSql

select Tunnus_report1