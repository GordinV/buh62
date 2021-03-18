l_file = 'c:/temp/rekl_122020'
USE (l_file) alias rekl
* BROWSE

CREATE CURSOR tmp_alg (konto c(20), regkood c(20), summa n(12,2))
SELECT rekl
SCAN
	l_str = left(ALLTRIM(rekl.n2), LEN(ALLTRIM(rekl.n2)) - 7)
	s_2 = RIGHT(l_str , 8)
	INSERT INTO tmp_alg  (konto, regkood, summa) VALUES (rekl.n1, s_2 , rekl.n3)
ENDSCAN

SELECT tmp_alg


l_json  = ''
SCAN FOR tmp_alg.summa > 0 AND !EMPTY(tmp_alg.regkood)
	TEXT TO l_json TEXTMERGE NOSHOW additive 
		<<IIF(LEN(l_json) > 1,',','')>> {"konto": "<<ALLTRIM(tmp_alg.konto)>>", "regkood":"<<ALLTRIM(tmp_alg.regkood)>>","summa":<<tmp_alg.summa>>}
	ENDTEXT	
ENDSCAN

l_json = '[' + l_json + ']'

USE IN rekl
USE IN tmp_alg

_cliptext = l_json