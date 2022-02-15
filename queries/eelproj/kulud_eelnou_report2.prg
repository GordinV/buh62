Parameter cWhere

Wait Window 'Päring...' Nowait

TEXT TO lcWhere TEXTMERGE noshow
	coalesce(tunnus,'') ilike '<<ALLTRIM(fltrAruanne.tunnus)>>%'
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
ENDTEXT

l_params = null
IF !EMPTY(fltrAruanne.kood2)
TEXT TO l_params TEXTMERGE noshow
l_params = '{"allikas":"<<ALLTRIM(fltrAruanne.kood2)>>"}'
ENDTEXT
	
ENDIF


lError = oDb.readFromModel('aruanned\eelarve\kulud_eelnou_detailne', 'kulud_eelnou', 'fltrAruanne.kpv2, gRekv,fltrAruanne.kond,l_params', 'tmp_eelnou_report',lcWhere)

If !lError OR !USED('tmp_eelnou_report')
	Messagebox('Viga',0+16, 'Tulud eelarve eelnõu')
	Set Step On
	Select 0
	Return .F.
Endif

*!*	CREATE CURSOR tulud_eelnou_report1(asutus c(254), tunnus c(20) null, tegev c(20) null, tegev_nimetus c(254) null, artikkel c(20), nimetus c(254),;
*!*	aasta_1_tekke_taitmine n(12,2), eelarve_tekkepohine_kinnitatud n(12,2), eelarve_tekkepohine_tapsustatud n(12,2), aasta_2_tekke_taitmine n(12,2),;
*!*	aasta_3_eelnou n(12,2), aasta_3_prognoos n(12,2), selg m null)

CREATE CURSOR tulud_eelnou_report1(parent_asutus c(254), asutus c(254),   tunnus c(20) null,; 
tegev c(20) null, tegev_nimetus c(254) null, ;
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