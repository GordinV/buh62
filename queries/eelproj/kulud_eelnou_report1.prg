Parameter cWhere

Wait Window 'Päring...' Nowait

TEXT TO lcWhere TEXTMERGE noshow
	coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
ENDTEXT

lcJson = null
IF !EMPTY(fltrAruanne.kood2)
	TEXT TO lcJson TEXTMERGE noshow
	{"allikas":"<<ALLTRIM(fltrAruanne.kood2)>>","taotlus_statusid":<<fltrAruanne.taotlus_statusid>>}
	ENDTEXT	
ELSE
* lisa params
TEXT TO lcJson TEXTMERGE noshow
	{"taotlus_statusid":<<fltrAruanne.taotlus_statusid>>}
ENDTEXT
	
ENDIF



lError = oDb.readFromModel('aruanned\eelarve\kulud_eelnou', 'kulud_eelnou', 'fltrAruanne.kpv2, gRekv,fltrAruanne.kond,lcJson', 'tmp_eelnou_report',lcWhere )

If !lError OR !USED('tmp_eelnou_report')
	Messagebox('Viga',0+16, 'Kulud eelarve eelnõu')
	Set Step On
	Select 0
	Return .F.
ENDIF

CREATE CURSOR tulud_eelnou_report1(asutus c(254), hallava_asutus c(254),   ;
artikkel c(20), nimetus c(254),;
aasta_1_tekke_taitmine n(12,2), ;
eelarve_tekkepohine_kinnitatud n(12,2), ;
eelarve_tekkepohine_tapsustatud n(12,2), ;
aasta_2_tekke_taitmine n(12,2),;
aasta_3_oodatav n(12,2) ,;
aasta_3_eelnou n(12,2),;
aasta_3_prognoos n(12,2),;
selg m DEFAULT ' ')



SELECT tulud_eelnou_report1
APPEND FROM DBF('tmp_eelnou_report')

USE IN tmp_eelnou_report


SELECT tulud_eelnou_report1
