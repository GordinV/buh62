Parameter cWhere

l_asutus = ''
l_params  = ''

IF !EMPTY(fltrAruanne.asutusid)
	SELECT comAsutusRemote
	LOCATE FOR id = fltrAruanne.asutusid
	l_asutus = ALLTRIM(comAsutusRemote.nimetus)
ENDIF

TEXT TO l_params TEXTMERGE noshow
	<<IIF(!EMPTY(fltrAruanne.konto),'Konto=','')>> <<ALLTRIM(fltrAruanne.konto)>> <<IIF(!EMPTY(fltrAruanne.konto),'%','')>> 
	<<IIF(!EMPTY(l_asutus),'Maksja=','')>> <<ALLTRIM(l_asutus)>>
ENDTEXT


IF !USED('fltrParametid')
	CREATE CURSOR fltrParametid (params m)
	APPEND BLANK
ENDIF

replace fltrParametid.params WITH l_params IN fltrParametid

l_kond = fltrAruanne.kond

TEXT TO lcWhere TEXTMERGE noshow
	coalesce(konto,'') like '<<ALLTRIM(fltrAruanne.konto)>>%'
	and maksja_nimi ilike '%<<ALLTRIM(l_asutus)>>%'
ENDTEXT

IF EMPTY(fltrAruanne.kond)
	TEXT TO lcWhere TEXTMERGE NOSHOW additive
		and rekvid = <<gRekv>>
	ENDTEXT
ENDIF



lError = oDb.readFromModel('aruanned\raamatupidamine\kond_ebatoenaolised', 'ebatoenaolised_report', 'gRekv,gUserId,fltrAruanne.kpv2', 'ebatoenaolised_report1', lcWhere)

If !lError
	Messagebox('Viga',0+16, 'Ebatoenaolised')
	Set Step On
	Select 0
	Return .F.
Endif

Select ebatoenaolised_report1

