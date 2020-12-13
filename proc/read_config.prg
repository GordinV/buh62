lcPath = Sys(5) + Sys(2003)+ '\config.xml'
lcCustomPath = Sys(5) + Sys(2003)+ '\custom\config.xml'

If File(lcCustomPath)
	lcPath = lcCustomPath
Endif

* check path and model availbility
If  !File(lcPath)
	Messagebox('Config not found',0 + 48,'Error')
ENDIF

lnRecords = Xmltocursor(lcPath,'v_config',512)
*512

* check for update in custom

If File(lcCustomPath)
	Select v_config
	Locate For Name = 'narvalv_db'
	If !Found()
* connection not available. Need to add
		Select * From v_config Into Cursor Connection
		USE IN v_config
		
		CREATE CURSOR v_config  (Name c(254), Description c(254), Type c(254),conn_str c(254))
		Insert Into v_config (Name, Description, Type,conn_str) ;
			VALUES ('narvalv_db','uus narvalv db','connection','DRIVER=PostgreSQL Unicode;DATABASE=db;server=80.235.127.119;PORT=5438;MaxVarcharSize=254;')

		APPEND FROM DBF('connection')
		USE IN connection
* save to xml
		Select * From v_config Into Cursor Connection
		USE IN v_config

		lnRecords = Cursortoxml('connection',lcPath,1, 512)
		If(lnRecords > 0)
			Wait Window 'Uus ühendus lisatud' Timeout 3
		Endif
		Use In Connection

	Endif
Endif

Select v_config
l_config = v_config.Name
If Reccount() > 1
	Do Form vali_config To l_config
Endif
Return l_config


TEXT
  <connection>
	<name>narvalv</name>
	<description>narvalv</description>
	<type>connection</type>
	<conn_str>DRIVER=PostgreSQL Unicode;DATABASE=narvalv;server=80.235.127.119;PORT=5438;MaxVarcharSize=254;</conn_str>
  </connection>
ENDTEXT
