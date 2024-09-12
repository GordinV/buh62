LPARAMETERS l_suletud, l_osalised_avatud 

l_status = 1

IF (l_suletud) 
* kinni		
	l_status = 0
ENDIF

IF (l_suletud) AND (l_osalised_avatud )
* osalised kinni
	l_status = 2
ENDIF

RETURN l_status 