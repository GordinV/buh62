LPARAMETERS tcSona
LOCAL lcReturnSona
lcReturnSona = ''

FOR i = 0 TO LEN(tcSona) 
	lcTaht = SUBSTR(tcSona,i,1)	
	?lcTaht
	DO CASE 
		CASE lcTaht = '�'
			lcTaht = '&#252;'
		CASE lcTaht = '�'
			lcTaht = '&#220;'
		CASE lcTaht = '�'
			lcTaht = '&#245;'
		CASE lcTaht = '�'
			lcTaht = '&#213;'
		CASE lcTaht = '�'
			lcTaht = '&#228;'
		CASE lcTaht = '�'
			lcTaht = '&#196;'
		CASE lcTaht = '�'
			lcTaht = '&#246;'
		CASE lcTaht = '�'
			lcTaht = '&#214;'
		CASE lcTaht = '�'
			lcTaht = '&#269;'
		CASE lcTaht = '�'
			lcTaht = '&#268;'
		CASE lcTaht = '�'
			lcTaht = '&#382;'
		CASE lcTaht = '�'
			lcTaht = '&#381;'
		CASE lcTaht = '�'
			lcTaht = '&#353;'
		CASE lcTaht = '�'
			lcTaht = '&#352;'
		CASE lcTaht = '&'
			lcTaht = '&#038;'
	ENDCASE
	lcReturnSona = lcReturnSona + lcTaht
ENDFOR

RETURN lcReturnSona
