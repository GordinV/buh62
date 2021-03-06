Parameter cWhere
l_vast_isik = ''
l_grupp = ''

IF !EMPTY(fltrAruanne.asutusid)
	SELECT comAsutusRemote
	LOCATE FOR id = fltrAruanne.asutusid
	l_vast_isik = comAsutusRemote.nimetus
ENDIF

IF !EMPTY(fltrAruanne.grupp)
	SELECT comGruppAruanne
	LOCATE FOR id = fltrAruanne.grupp
	l_grupp = comGruppAruanne.nimetus

ENDIF


TEXT TO lcWhere TEXTMERGE noshow
	konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
	and grupp ilike '%<<ALLTRIM(l_grupp)>>%'
	and vastisik ilike '%<<ALLTRIM(l_vast_isik)>>%'
ENDTEXT

lError = oDb.readFromModel('aruanned\pv\pv_kaibearuanne', 'pv_kaibe_aruanne_report', 'fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv', 'tmp_report',lcWhere)
If !lError
	Messagebox('Viga',0+16, 'PV käibearuanne')
	Set Step On
	SELECT 0
	RETURN .f.
Endif

SELECT * from tmp_report ORDER BY konto, kood INTO CURSOR kaibearuanne_report1

USE IN tmp_report

SELECT kaibearuanne_report1
