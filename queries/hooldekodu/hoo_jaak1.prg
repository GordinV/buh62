Parameter cWhere

TEXT TO lcWhere TEXTMERGE noshow
	(isikukood like '<<allTRIM(fltrHooIsikud.isik)>>%'
	or nimi ilike '%<<allTRIM(fltrHooIsikud.isik)>>%')
ENDTEXT


l_params  = ''
TEXT TO l_params TEXTMERGE noshow
	<<IIF(!EMPTY(fltrHooIsikud.isik),'Isik=','')>> <<ALLTRIM(fltrHooIsikud.isik)>> <<IIF(!EMPTY(fltrHooIsikud.isik),'%','')>> 
ENDTEXT

IF !USED('fltrParametid')
	CREATE CURSOR fltrParametid (params m)
	APPEND BLANK
ENDIF

replace fltrParametid.params WITH l_params IN fltrParametid

lError = oDb.readFromModel('hooldekodu\hooisik', 'print_hoojaagid', 'gRekv,gUserid', 'hoojaak1', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Hooldekodu')
	Set Step On
	Select 0
	Return .F.
Endif
Select hoojaak1
