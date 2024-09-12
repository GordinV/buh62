Parameter cWhere

cdkehtivus = "date("+Str(Year(fltrHooIsikud.kehtivus),4)+","+Str(Month(fltrHooIsikud.kehtivus),2)+","+Str(Day(fltrHooIsikud.kehtivus),2)+")"

If Isdigit(Ltrim(Rtrim(fltrHooIsikud.isik)))
* see on reg.kood
	tcRegnum = Ltrim(Rtrim(fltrHooIsikud.isik))+'%'
	tcNimetus = '%'
Else
* see on nimetus
	tcRegnum = '%'
	tcNimetus = Ltrim(Rtrim(fltrHooIsikud.isik))+'%'
Endif

TEXT TO lcWhere TEXTMERGE noshow
	fix_text(nimi::text) ilike '%<<tcNimetus>>%'
	and isikukood ilike '%<<tcRegnum>>%'
	and hooldekodu ilike '<<%ltrim(rtrim(fltrHooIsikud.hooldekodu))>>%'
	and algkpv <= <<cdkehtivus>>
	and coalesce(loppkpv,DATE()) >= <<cdkehtivus>>

ENDTEXT

l_params  = ''
TEXT TO l_params TEXTMERGE noshow
	<<IIF(!EMPTY(fltrHooIsikud.isik),'Isik=','')>> <<ALLTRIM(fltrHooIsikud.isik)>> <<IIF(!EMPTY(fltrHooIsikud.isik),'%','')>> 
ENDTEXT
TEXT TO l_params TEXTMERGE noshow
	<<IIF(!EMPTY(fltrHooIsikud.hooldekodu),'Hooldekodu=','')>> <<ALLTRIM(fltrHooIsikud.hooldekodu)>> <<IIF(!EMPTY(fltrHooIsikud.hooldekodu),'%','')>> 
ENDTEXT

TEXT TO l_params TEXTMERGE NOSHOW additive
alg.kpv <= <<DTOC(fltrHooIsikud.kehtivus ,1)>>, lõpp.kpv >= <<DTOC(fltrHooIsikud.kehtivus ,1)>>
ENDTEXT


IF !USED('fltrParametid')
	CREATE CURSOR fltrParametid (params m)
	APPEND BLANK
ENDIF

replace fltrParametid.params WITH l_params IN fltrParametid

lError = oDb.readFromModel('hooldekodu\hooleping', 'curHooLeping', 'gRekv,gUserid', 'hooleping1', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Hooldekodu')
	Set Step On
	Select 0
	Return .F.
Endif
Select hooleping1

