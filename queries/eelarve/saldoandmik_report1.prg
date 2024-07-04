 PARAMETER tcWhere
  

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and konto like '<<ALLTRIM(fltrAruanne.kood4)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.kood2)>>%'
	and (deebet <> 0 or kreedit <> 0)
ENDTEXT

l_params  = ''
TEXT TO l_params TEXTMERGE noshow
	<<IIF(!EMPTY(fltrAruanne.kood4),'Konto=','')>> <<ALLTRIM(fltrAruanne.kood4)>> <<IIF(!EMPTY(fltrAruanne.kood4),'%','')>> 
ENDTEXT

TEXT TO l_params TEXTMERGE NOSHOW additive
	<<IIF(!EMPTY(fltrAruanne.tunnus),IIF(LEN(l_params)> 0 ,', ','') + 'Tunnus=','')>> <<ALLTRIM(fltrAruanne.tunnus)>> <<IIF(!EMPTY(fltrAruanne.tunnus),'%','')>> 
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive	
	<<IIF(!EMPTY(fltrAruanne.proj),IIF(LEN(l_params)> 0 ,', ','') + 'Projekt=','')>> <<ALLTRIM(fltrAruanne.proj)>> <<IIF(!EMPTY(fltrAruanne.proj),'%','')>> 
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive		
	<<IIF(!EMPTY(fltrAruanne.uritus),IIF(LEN(l_params)> 0 ,', ','') + 'Üritus=','')>> <<ALLTRIM(fltrAruanne.uritus)>> <<IIF(!EMPTY(fltrAruanne.uritus),'%','')>> 
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive		
	<<IIF(!EMPTY(fltrAruanne.kood1),IIF(LEN(l_params)> 0 ,', ','') + 'Tegevus=','')>> <<ALLTRIM(fltrAruanne.kood1)>> <<IIF(!EMPTY(fltrAruanne.kood1),'%','')>> 
ENDTEXT

TEXT TO l_params TEXTMERGE NOSHOW additive		
	<<IIF(!EMPTY(fltrAruanne.tp),IIF(LEN(l_params)> 0 ,', ','') + 'TP=','')>> <<ALLTRIM(fltrAruanne.tp)>> <<IIF(!EMPTY(fltrAruanne.tp),'%','')>> 
ENDTEXT

IF !USED('fltrParametid')
	CREATE CURSOR fltrParametid (params m)
	APPEND BLANK
ENDIF



replace fltrParametid.params WITH l_params IN fltrParametid

TEXT TO l_params TEXTMERGE noshow
	{
		"id":"1",
		"tunnus":"<<ALLTRIM(fltrAruanne.tunnus)>>",
		"konto":"<<ALLTRIM(fltrAruanne.konto)>>",
		"proj":"<<ALLTRIM(fltrAruanne.proj)>>",
		"uritus":"<<ALLTRIM(fltrAruanne.uritus)>>",
		"tegevus":"<<ALLTRIM(fltrAruanne.kood1)>>",
		"tp":"<<ALLTRIM(fltrAruanne.tp)>>"
	}
ENDTEXT

l_kpv1 = fltrAruanne.kpv1
l_kpv2 = fltrAruanne.kpv2
l_kond = IIF(EMPTY(fltrAruanne.kond), null, 1)

lError = oDb.readFromModel('aruanned\eelarve\saldoandmik', 'saldoandmik_report', 'l_kpv2, gRekv, l_kond, l_params', 'saldoaruanne_report1', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve kulud')
	Set Step On
	Select 0
	Return .F.
ENDIF

Select saldoaruanne_report1

IF !EMPTY(fltrAruanne.kond) AND !EMPTY(fltrAruanne.ainult_kond)
	SET FILTER TO rekv_id = 999999
	GO TOP 
ENDIF
