Parameter tcWhere
lcWhere = ''
lcWhere = Iif(Empty(fltrAruanne.kond),' qry.rekv_id = ' + Str(gRekv), '')
l_kond = fltrAruanne.kond


TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
	<<IIF(LEN(lcWhere) > 0, 'and', '')>> konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
ENDTEXT

l_params  = ''
TEXT TO l_params TEXTMERGE noshow
	<<IIF(!EMPTY(fltrAruanne.konto),'Konto=','')>> <<ALLTRIM(fltrAruanne.konto)>> <<IIF(!EMPTY(fltrAruanne.konto),'%','')>> 
ENDTEXT

TEXT TO l_params TEXTMERGE NOSHOW additive
	<<IIF(!EMPTY(fltrAruanne.tunnus),IIF(LEN(l_params)> 0 ,', ','') + 'Tunnus=','')>> <<ALLTRIM(fltrAruanne.tunnus)>> <<IIF(!EMPTY(fltrAruanne.tunnus),'%','')>> 
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive	
	<<IIF(!EMPTY(fltrAruanne.proj),IIF(LEN(l_params)> 0 ,', ','') + 'Projekt=','')>> <<ALLTRIM(fltrAruanne.proj)>> <<IIF(!EMPTY(fltrAruanne.proj),'%','')>> 
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive		
	<<IIF(!EMPTY(fltrAruanne.uritus),IIF(LEN(l_params)> 0 ,', ','') + '�ritus=','')>> <<ALLTRIM(fltrAruanne.uritus)>> <<IIF(!EMPTY(fltrAruanne.uritus),'%','')>> 
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive		
	<<IIF(!EMPTY(fltrAruanne.objekt),IIF(LEN(l_params)> 0 ,', ','') + 'Objekt=','')>> <<ALLTRIM(fltrAruanne.objekt)>> <<IIF(!EMPTY(fltrAruanne.objekt),'%','')>> 
ENDTEXT

IF !USED('fltrParametid')
	CREATE CURSOR fltrParametid (params m)
	APPEND BLANK
ENDIF
replace fltrParametid.params WITH l_params IN fltrParametid


TEXT TO l_params TEXTMERGE noshow
	{
		"tunnus":"<<ALLTRIM(fltrAruanne.tunnus)>>",
		"konto":"<<ALLTRIM(fltrAruanne.konto)>>",
		"proj":"<<ALLTRIM(fltrAruanne.proj)>>",
		"uritus":"<<ALLTRIM(fltrAruanne.uritus)>>",
		"tegevus":"<<ALLTRIM(fltrAruanne.kood1)>>",
		"objekt":"<<ALLTRIM(fltrAruanne.objekt)>>"
	}
ENDTEXT



lError = oDb.readFromModel('aruanned\raamatupidamine\kontosaldoandmik', 'kontosaldoandmik_report', 'alltrim(fltrAruanne.konto),fltrAruanne.asutusid, fltrAruanne.kpv2, gRekv,l_kond, l_params', 'kaibeAsutusandmik_report1', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Konto saldoandmik')
	Set Step On
	Select 0
	Return .F.
Endif

Select kaibeAsutusandmik_report1
