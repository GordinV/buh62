Parameter cWhere

IF !USED('curTunnus')
	SELECT 0
	RETURN .f.
ENDIF
SELECT curTunnus
lcTag = TAG()
*
TEXT TO lcSql TEXTMERGE noshow
	SELECT * from curTunnus ORDER BY <<IIF(EMPTY(lcTag),'id',lcTag)>> into CURSOR tunnus_report1
ENDTEXT

&lcSql

IF !USED('tunnus_report1')
	SELECT 0
	RETURN .f.
ENDIF

select Tunnus_report1