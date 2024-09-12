Parameter cWhere
cReportName = 'Asutuste järgi'

IF fltrAruanne.arvestus = 1 AND gRekv = 63
	WAIT WINDOW 'Re-arvestan ...' nowait
	lError = oDb.readFromModel('aruanned\eelarve\lisa1_lisa5_kontrol_asutuste_jargi', 'koosta_lisa1_lisa5_kontrol', 'gUserId,fltrAruanne.kpv2', 'tmpTulemus')
	If !lError
		Messagebox('Viga',0+16, 'Lisa1 - Lisa5 kontrol')
		Set Step On
		Select 0
		Return .F.
	ENDIF
	replace fltrAruanne.arvestus WITH 0 IN fltrAruanne
	WAIT WINDOW 'Arvestan ...tehtud' nowait
ENDIF

CREATE CURSOR tmp_report_name (name c(20))
INSERT INTO tmp_report_name  VALUES ('Asutuste järgi')

Wait Window 'Päring...' Nowait

lError = oDb.readFromModel('aruanned\eelarve\lisa1_lisa5_kontrol_asutuste_jargi', 'lisa1_lisa5_kontrol', 'fltrAruanne.kpv2, gRekv, fltrAruanne.kond', 'eelarve_report')
If !lError
	Messagebox('Viga',0+16, 'Lisa1 - Lisa5 kontrol')
	
	Set Step On
	Select 0
	Return .F.
ENDIF

SELECT * from eelarve_report ;
WHERE   eelarve <> 0 OR  eelarve_kassa <> 0 OR eelarve_taps <> 0 OR kassa <> 0 OR saldoandmik <> 0 ;
INTO CURSOR  eelarve_report1              

IF RECCOUNT('eelarve_report1') = 0 AND RECCOUNT('eelarve_report') > 0 
	MESSAGEBOX('Vead ei ole')
	SELECT 0
	RETURN .f.
ENDIF

IF RECCOUNT('eelarve_report') = 0 
	MESSAGEBOX('Andmed puuduvad, vale period')
	SELECT 0
	RETURN .f.
ENDIF

SELECT eelarve_report1

                            


