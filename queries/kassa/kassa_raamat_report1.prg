Parameter cWhere

lcWhere = ''
lcWhere = IIF(EMPTY(fltrAruanne.kond),' rekv_id = ' + STR(gRekv), '')

lError = oDb.readFromModel('aruanned\raamatupidamine\kassa_raamat', 'kassa_raamat',; 
	'fltrAruanne.kpv1, fltrAruanne.kpv2, gRekv', 'tmpReport', lcWhere)
If !lError
	Messagebox('Viga',0+16, 'Kaibeasutusandmik')
	Set Step On
	SELECT 0
	RETURN .f.
Endif

SELECT * ;
	FROM tmpReport ;
	WHERE alus <> 'Alg. saldo';
	ORDER BY rekv_id,  kassa, kpv  ;
	INTO CURSOR kassaraamat_report1

USE IN tmpReport

SELECT kassaraamat_report1
