lcPath = Sys(5) + Sys(2003)+ '\config.xml'

* check path and model availbility
If  !File(lcPath)
	Messagebox('Config not found',0 + 48,'Error')
ENDIF

lnRecords = Xmltocursor(lcPath,'v_config',512) 
*512

Select v_config