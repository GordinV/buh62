Parameter cWhere

TEXT TO lcWhere TEXTMERGE noshow
	(isikukood like '<<allTRIM(fltrHooIsikud.isik)>>%'
	or nimi ilike '%<<allTRIM(fltrHooIsikud.isik)>>%')
	and hooldekodu ilike '%<<ALLTRIM(fltrHooIsikud.hooldekodu)>>%'
	and kuu >= <<fltrHooTaabel.kuu1>>
	and kuu <= <<fltrHooTaabel.kuu2>>
	and aasta = <<fltrHooTaabel.aasta>>
	and number ilike '%<<ALLTRIM(fltrHooTaabel.arvnumber)>>%'
ENDTEXT


l_params  = ''
TEXT TO l_params TEXTMERGE noshow
	<<IIF(!EMPTY(fltrHooIsikud.isik),'Isik=','')>> <<ALLTRIM(fltrHooIsikud.isik)>> <<IIF(!EMPTY(fltrHooIsikud.isik),'%','')>> 
ENDTEXT

TEXT TO l_params TEXTMERGE NOSHOW additive
	<<IIF(!EMPTY(fltrHooIsikud.hooldekodu),IIF(LEN(l_params)> 0 ,', ','') + 'Hooldekodu=','')>> <<ALLTRIM(fltrHooIsikud.hooldekodu)>> <<IIF(!EMPTY(fltrHooIsikud.hooldekodu),'%','')>> 
ENDTEXT

TEXT TO l_params TEXTMERGE NOSHOW additive
Kuu>= <<fltrHooTaabel.kuu1>>, kuu <= <<fltrHooTaabel.kuu2>>, aasta = <<fltrHooTaabel.aasta>>
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive
	<<IIF(!EMPTY(fltrHooTaabel.arvnumber),IIF(LEN(l_params)> 0 ,', ','') + 'Arve number=','')>> <<ALLTRIM(fltrHooTaabel.arvnumber)>> <<IIF(!EMPTY(fltrHooTaabel.arvnumber),'%','')>> 
ENDTEXT

IF !USED('fltrParametid')
	CREATE CURSOR fltrParametid (params m)
	APPEND BLANK
ENDIF

replace fltrParametid.params WITH l_params IN fltrParametid

lError = oDb.readFromModel('hooldekodu\hootaabel', 'curHooTaabel', 'gRekv,gUserid', 'hootaabel1', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve tulud')
	Set Step On
	Select 0
	Return .F.
Endif
Select hootaabel1
