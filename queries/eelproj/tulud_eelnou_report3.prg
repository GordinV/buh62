Parameter cWhere

Wait Window 'Päring...' Nowait

TEXT TO lcWhere TEXTMERGE noshow
	coalesce(tunnus,'') ilike '<<ALLTRIM(fltrAruanne.tunnus)>>%'
	and coalesce(proj,'') ilike '<<ALLTRIM(fltrAruanne.proj)>>%'
	and coalesce(uritus,'') ilike '<<ALLTRIM(fltrAruanne.uritus)>>%'
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(allikas,'') like '<<ALLTRIM(fltrAruanne.kood2)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and coalesce(objekt,'') like '<<ALLTRIM(fltrAruanne.objekt)>>%'
ENDTEXT

* lisa params
TEXT TO lcJson TEXTMERGE noshow
	{"taotlus_statusid":<<fltrAruanne.taotlus_statusid>>}
ENDTEXT

lError = oDb.readFromModel('aruanned\eelarve\tulud_eelnou_detailne_pikk', 'tulud_eelnou', 'fltrAruanne.kpv2, gRekv,fltrAruanne.kond,lcJson', 'tmp_eelnou_report',lcWhere)

If !lError OR !USED('tmp_eelnou_report')
	Messagebox('Viga',0+16, 'Tulud eelarve eelnõu')
	Set Step On
	Select 0
	Return .F.
Endif

CREATE CURSOR tulud_eelnou_report1(parent_asutus c(254), asutus c(254),   tunnus c(20) null, ;
proj c(20) null, uritus c(20) null, objekt c(20) null,  tegev c(20) null, tegev_nimetus c(254) null, ;
artikkel c(20), nimetus c(254),allikas c(20),;
aasta_1_tekke_taitmine n(12,2) DEFAULT 0, ;
eelarve_tekkepohine_kinnitatud n(12,2) DEFAULT 0, ;
eelarve_tekkepohine_tapsustatud n(12,2) DEFAULT 0, ;
aasta_2_tekke_taitmine n(12,2) DEFAULT 0,;
aasta_2_oodatav_taitmine n(12,2) DEFAULT 0,;
aasta_3_eelnou n(12,2) DEFAULT 0,;
aasta_3_prognoos  n(12,2) DEFAULT 0,;
selg m DEFAULT '')

SELECT tulud_eelnou_report1
APPEND FROM DBF('tmp_eelnou_report')

*UPDATE tulud_eelnou_report1 SET tunnus = alltrim(tunnus) + '-', tegev = ALLTRIM(tegev) + '-', tegev_nimetus  = ALLTRIM(tegev_nimetus ) + '-' , allikas = ALLTRIM(allikas) + '-'

USE IN tmp_eelnou_report