LPARAMETERS tcSona
LOCAL lcReturnSona
lcReturnSona = ''

IF ISNULL(tcSona)
	RETURN lcReturnSona
endif

FOR i = 0 TO LEN(tcSona) 
	lcTaht = SUBSTR(tcSona,i,1)	
	?lcTaht
	DO CASE 
		CASE lcTaht = 'ü'
			lcTaht = '&#252;'
		CASE lcTaht = 'Ü'
			lcTaht = '&#220;'
		CASE lcTaht = 'õ'
			lcTaht = '&#245;'
		CASE lcTaht = 'Õ'
			lcTaht = '&#213;'
		CASE lcTaht = 'ä'
			lcTaht = '&#228;'
		CASE lcTaht = 'Ä'
			lcTaht = '&#196;'
		CASE lcTaht = 'ö'
			lcTaht = '&#246;'
		CASE lcTaht = 'Ö'
			lcTaht = '&#214;'
		CASE lcTaht = 'è'
			lcTaht = '&#269;'
		CASE lcTaht = 'È'
			lcTaht = '&#268;'
		CASE lcTaht = 'þ'
			lcTaht = '&#382;'
		CASE lcTaht = 'Þ'
			lcTaht = '&#381;'
		CASE lcTaht = 'ð'
			lcTaht = '&#353;'
		CASE lcTaht = 'Ð'
			lcTaht = '&#352;'
		CASE lcTaht = '&'
			lcTaht = '&amp;'
		CASE lcTaht = "'"
			lcTaht = '&apos;'
		CASE lcTaht = '"'
			lcTaht = '&quot;'
		CASE lcTaht = '>'
			lcTaht = '&gt;'
		CASE lcTaht = '<'
			lcTaht = '&lt;'
					
	ENDCASE
	lcReturnSona = lcReturnSona + lcTaht
ENDFOR

RETURN lcReturnSona
