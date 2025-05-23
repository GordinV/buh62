LPARAMETERS tcParams
* https://www.rtk.ee/sites/default/files/yldeeskiri_lisa920loplik.pdf

*!*		SET STEP on
*!*	gRekv = 64
*!*	CREATE CURSOR fltrAruanne (kpv2 d, kond i)
*!*	APPEND BLANK
*!*	replace kpv2 WITH DATE(2019,01,03), kond WITH 0
*!*	 
*!*	gnHandle = SQLCONNECT('NarvaLvPg','vlad','Vlad490710')
*!*	 

TEXT TO lcWhere TEXTMERGE noshow
	(EMPTY(<<fltrAruanne.asutusid>>) or rekv_id = <<fltrAruanne.asutusid>>)
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood4)>>%'
	and coalesce(artikkel,'') like '<<ALLTRIM(fltrAruanne.kood5)>>%'
	and coalesce(tegev,'') like '<<ALLTRIM(fltrAruanne.kood1)>>%'
	and summa >= <<fltrAruanne.summa>>
ENDTEXT

If Empty(fltrAruanne.kond)
	TEXT TO lcWhere ADDITIVE TEXTMERGE noshow
			and rekv_id = <<gRekv>>
	ENDTEXT
ENDIF

WAIT WINDOW 'P�ring...' nowait

lError = oDb.readFromModel('aruanned\eelarve\lisa_9', 'lisa_9', 'fltrAruanne.kpv1, fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'eelarve_report1', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Eelarve t�itmine')
	Set Step On
	Select 0
	Return .F.
Endif


SELECT eelarve_report1
