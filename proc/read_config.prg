lcPath = Sys(5) + Sys(2003)+ '\config.xml'
lcCustomPath = Sys(5) + Sys(2003)+ '\custom\config.xml'

IF File(lcCustompath)
	lcPath = lcCustomPath
ENDIF

* check path and model availbility
If  !File(lcPath)
	Messagebox('Config not found',0 + 48,'Error')
ENDIF

lnRecords = Xmltocursor(lcPath,'v_config',512) 
*512

Select v_config
l_config = v_config.name
IF RECCOUNT() > 1
	DO FORM vali_config TO l_config
ENDIF
RETURN l_config