Parameter cWhere

IF USED('tmpReport')
	USE IN tmpReport
ENDIF

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

TEXT TO l_params TEXTMERGE NOSHOW additive		
	<<IIF(!EMPTY(fltrAruanne.kood1),IIF(LEN(l_params)> 0 ,', ','') + 'Tegevus=','')>> <<ALLTRIM(fltrAruanne.kood1)>> <<IIF(!EMPTY(fltrAruanne.kood1),'%','')>> 
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive		
	<<IIF(!EMPTY(fltrAruanne.kood2),IIF(LEN(l_params)> 0 ,', ','') + 'Allikas=','')>> <<ALLTRIM(fltrAruanne.kood2)>> <<IIF(!EMPTY(fltrAruanne.kood2),'%','')>> 
ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive		
	<<IIF(!EMPTY(fltrAruanne.kood5),IIF(LEN(l_params)> 0 ,', ','') + 'Artikkel=','')>> <<ALLTRIM(fltrAruanne.kood5)>> <<IIF(!EMPTY(fltrAruanne.kood5),'%','')>> 
ENDTEXT


IF !USED('fltrParametid')
	CREATE CURSOR fltrParametid (params m)
	APPEND BLANK
ENDIF

l_where = '1=1'

IF !EMPTY(fltrAruanne.asutusid) 
	SELECT comRekvRemote
	LOCATE FOR id = fltrAruanne.asutusid
	IF FOUND()
	TEXT TO l_where noshow
		asutus = '<<ALLTRIM(comRekvRemote.nimetus)>>'
	ENDTEXT
TEXT TO l_params TEXTMERGE NOSHOW additive		
	Asutus=<<ALLTRIM(comRekvRemote.nimetus)>> 
ENDTEXT
	
	ENDIF
	
ENDIF

replace fltrParametid.params WITH l_params IN fltrParametid

TEXT TO l_params TEXTMERGE noshow
	{
		"tunnus":"<<ALLTRIM(fltrAruanne.tunnus)>>",
		"konto":"<<ALLTRIM(fltrAruanne.konto)>>",
		"proj":"<<ALLTRIM(fltrAruanne.proj)>>",
		"uritus":"<<ALLTRIM(fltrAruanne.uritus)>>",
		"artikkel":"<<ALLTRIM(fltrAruanne.kood5)>>",
		"tegevus":"<<ALLTRIM(fltrAruanne.kood1)>>",
		"allikas":"<<ALLTRIM(fltrAruanne.kood2)>>",
		"kond":<<fltrAruanne.kond>>,
		"asutus_id":<<fltrAruanne.asutusid>>,
		"objekt":"<<ALLTRIM(fltrAruanne.objekt)>>"
	}
ENDTEXT


lError = oDb.readFromModel('aruanned\raamatupidamine\vara_majanduskulud', 'vara_majanduskulud_report', 'fltrAruanne.kpv1,fltrAruanne.kpv2,gRekv,l_params', 'vara_majanduskulud_report1', l_where )

If !lError
	Messagebox('Viga',0+16, 'Kulud')
	Set Step On
	SELECT 0
	RETURN .f.
Endif

SELECT vara_majanduskulud_report1