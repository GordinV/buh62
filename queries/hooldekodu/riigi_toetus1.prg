Parameter cWhere

IF !USED('curHooConfig')
	SELECT 0
	RETURN .f.
ENDIF

SELECT curHooConfig
lcTag = TAG()

If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))

TEXT TO lcSql TEXTMERGE noshow
	SELECT * from curHooConfig  where id = <<cWhere>> INTO CURSOR riigi_toetus_report1
ENDTEXT

ELSE
TEXT TO lcSql TEXTMERGE noshow
	SELECT * from curHooConfig ORDER BY <<IIF(EMPTY(lcTag),'id',lcTag)>> into CURSOR riigi_toetus_report1
ENDTEXT

Endif

&lcSql

IF !USED('riigi_toetus_report1')
	SELECT 0
	RETURN .f.
ENDIF

select riigi_toetus_report1