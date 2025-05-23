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

SET STEP on	
TEXT TO lcWhere TEXTMERGE noshow
	konto ilike '<<ALLTRIM(fltrAruanne.konto)>>%'
	and grupp ilike '%<<ALLTRIM(l_grupp)>>%'
	and vastisik ilike '%<<ALLTRIM(l_vast_isik)>>%'
ENDTEXT

TEXT TO lcJson TEXTMERGE noshow
		{"konto": "<<ALLTRIM(fltrAruanne.konto )>>",
		"grupp": "<<ALLTRIM(l_grupp)>>",
		"vastisik": "<<ALLTRIM(l_vast_isik)>>"}
ENDTEXT


lError = oDb.readFromModel('aruanned\pv\pv_rv_kaibearuanne', 'pv_rv_kaibe_aruanne_report', 'fltrAruanne.kpv1,fltrAruanne.kpv2, gRekv,fltrAruanne.kond,lcJson ', 'kaibearuanne_report',lcWhere)

If !lError
	Messagebox('Viga',0+16, 'PV käibearuanne')
	Set Step On
	SELECT 0
	RETURN .f.
ENDIF


CREATE CURSOR  kaibearuanne_report1 (kood c(20),;
        nimetus c(254),;
        konto c(20),;
        esimise_kpv   d,;
        alg_soetmaks  N(12, 2),;
        alg_kulum     N(12, 2),;
        kb_pv_rv01    N(12, 2),;
        kb_pv_rv19    N(12, 2),;         
        kb_pv_rv14    N(12, 2),;
        kb_pv_rv13    N(12, 2),; 
        kb_pv_rv15    N(12, 2),; 
        kb_pv_rv16    N(12, 2),; 
        kb_pv_rv23    N(12, 2),;
        kb_pv_rv17    N(12, 2),;
        kb_pv_rv24    N(12, 2),;
        kb_pv_rv29    N(12, 2),;
        kb_pv_rv21    N(12, 2),;
        kb_pv_rv02    N(12, 2),;
        kb_pv_rv12    N(12, 2),;
        lopp_soetmaks n(12, 2),;
        kb_kulum_rv11 n(12, 2),;
        kb_kulum_rv02 n(12, 2),;
        kb_kulum_rv12 n(12, 2),;
        kb_kulum_rv14 n(12, 2),;
        kb_kulum_rv13 n(12, 2),;
        kb_kulum_rv15 n(12, 2),;
        kb_kulum_rv16 n(12, 2),;
        kb_kulum_rv17 n(12, 2),;
        kb_kulum_rv24 n(12, 2),;
        kb_kulum_rv29 n(12, 2),;
        lopp_kulum    n(12, 2),;
        vastisik      C(254),;
        asutus        C(254))


SELECT kaibearuanne_report1
APPEND FROM DBF('kaibearuanne_report')

USE IN kaibearuanne_report
