Parameter gversia, tlDebug
&& ������� ���� �������, ������ ��������� � �������� ���-�� �������
grekv = 1
guSerid = 1
gversia ='VFP'
If Empty (gversia)
	Close Data All
	gversia = 'PG'
Endif
Do Case
	Case gversia = 'VFP'
		gnhandle = 1
		glError = .F.
*!*			cData = 'c:\buh50\dbavpsoft\buhdata5.dbc'
*!*			Open Data (cData)
		SET DATABASE TO buhdata5
		
	Case gversia = 'MSSQL'
		gnhandle = SQLConnect ('buhdata5local')
	Case gversia = 'PG'
		gnhandle = SQLConnect ('postgres','vlad')
Endcase

If gnhandle < 1
	Messagebox ('Viga: connection','Kontrol')
	Return
Endif
If !Used ('testlog')
	Create Cursor testlog (Log m)
Endif
Select testlog
Appen Blank
Replace testlog.Log With 'FUNCTION CHECK_RAAMAT_AEG' Additive
If !Used ('menuitem')
	Use menuitem In 0
Endif
If !Used ('menubar')
	Use menubar In 0
Endif
If !Used ('config')
	Use config In 0
Endif
Set Classlib To classes\Classlib
oDb = Createobject('db')
With oDb

	.login = 'VLAD'
	.Pass = ''

	Create Cursor curKey (versia m)
	Append Blank
	Replace versia With 'RAAMA' In curKey
	Create Cursor v_account (admin Int Default 1)

	tnLevel = 1
	tcpadname = ''
	
	lcModul = Iif('RAAMA' $ curKey.versia,'RAAMA','')
	lcModul1 = Iif('PALK' $ curKey.versia,'PALK','')
	lcModul2 = Iif('POHIVARA' $ curKey.versia,'POHIVARA','')
	lcModul3 = Iif('LADU' $ curKey.versia,'LADU','')
	lcModul4 = Iif('EELARVE' $ curKey.versia,'EELARVE','')
	lcModul5 = Iif('TEEN' $ curKey.versia,'TEEN','')
	lError = oDb.Exec ("sp_menu",;
		str (tnlevel,1)+","+Alltrim(Str (guSerid))+",'"+(tcPadname)+"','"+;
		lcModul+"','"+lcModul1+"','"+lcModul2+"','"+lcModul3+"','"+lcModul4+"','"+lcModul5+"'",;
		'curMenuRemote')
	IF !USED('curMenuRemote')
		MESSAGEBOX('Viga')
		RETURN
	ELSE
		SELECT curmenuRemote
		INDEX ON STR(level_,1)+'-'+LTRIM(RTRIM(bar))+'-'+STR(idx,2)+'-'+LTRIM(RTRIM(pad)) TAG idx
		SET ORDER TO idx
	ENDIF
	IF VARTYPE(oMenu) <> 'O' OR ISNULL(oMenu)
		SET CLASSLIB TO classes\menus6
		oMenu = createOBJECT( '_mnuMenuBar', 3 )
	ENDIF
*	SELECT * from curMenuRemote WHERE EMPTY(bar) INTO CURSOR qryBar
	IF tnLevel = 1
		Set sysmenu to
		Set sysmenu automatic

	endif	
	SCAN FOR EMPTY(bar)
		lcCaption = IIF(config.keel = 2,'EST ',IIF(config.keel = 1,'RUS ','ENG '))+'CAPTION'
		lnMemoLine = ATCLINE(lcCaption,curMenuRemote.omandus)
		IF lnMemoLine > 0
			lccaption = MLINE(curMenuRemote.omandus,lnMemoLine)
			lcCaption = SUBSTR(lcCaption,5+8,LEN(lcCaption))
			oMenu.AddMenu(LTRIM(RTRIM(curMenuRemote.pad)),lcCaption)
*			oMenu.addMenu('Test','Test1')
		endif
	ENDSCAN
	
	ON KEY LABEL esc set sysmenu to default
	SCAN FOR !EMPTY(bar)
		lcCaption = IIF(config.keel = 2,'EST ',IIF(config.keel = 1,'RUS ','ENG '))+'CAPTION'
		lnMemoLine = ATCLINE(lcCaption,curMenuRemote.omandus)
		lcCaption = IIF(lnMemoLine > 0,;
				SUBSTR(MLINE(curMenuRemote.omandus,lnMemoLine),5+8,;
				LEN(MLINE(curMenuRemote.omandus,lnMemoLine))),curMenuRemote.pad)
		lcPad = LTRIM(RTRIM(curmenuRemote.pad))
		lnbar = LTRIM(RTRIM(curmenuRemote.bar))
		lcBar = 'm'+SYS(2007,lcCaption)
		lcMenuObjekt = "oMenu."+lcPad+"."+lcbar		
		lcString = "oMenu."+lcPad+".addBar( '"+lcBar+"','\<"+lcCaption+"',"+lnbar+")"
		&lcString
		WITH oMenu
			lcString = lcMenuObjekt+".command = 'execmenu("+STR(curmenuRemote.id)+")'"
			&lcString
		endwith
*!*			   	.Command      = 
*!*	   			.Message      = "This is test one's message"
*!*	   			.KeyShortCut  = "Ctrl-F12"
*!*	   			.KeySCText    = "Ctrl-F12"
	ENDSCAN
	oMenu.define()
*!*		MESSAGEBOX('Ok')
*!*		SET SYSMENU TO default
*!*		CLEAR ALL
	READ events
	
	RETURN
	

*!*	oMenu.Extra.AddBar( 'SP100', '\-' )
*!*	oMenu.Extra.AddBar( 'Bar2', 'Test \<2' )

*!*	WITH oMenu.Extra.Bar2
*!*	   .Command     = "wait window 'Hello Test 2'"
*!*	   .Message     = "This is test two's message"
*!*	   .KeyShortCut = "Ctrl-F11"
*!*	   .FontName    = 'Arial'
*!*	   .FontSize    = 12
*!*	   .FontBold    = .T.
*!*	ENDWITH
*!*		
*!*		
*!*			SET CLASSLIB TO classes\menus6
*!*			oMenu = createobject( '_mnuMenubar')		
*!*		ENDIF
*!*		
*!*		oMenu.File.AddBar( 'new' )

*!*		With oMenu.File.new
*!*			.Caption     = '\<New...'
*!*			.Command     = 'DO newfile.prg'
*!*			.KeyShortcut = 'Ctrl-N'
*!*			.Message     = 'Create a new file'
*!*		Endwith

&& �������� ���-�� �������
	lnrecno1 = read_tbl()
	If Vartype (lnrecno1)= 'C'
		lnrecno1 = Val (Alltrim(lnrecno1))
	Endif
	Replace testlog.Log With '1 RECNO(RAAMAT):'+Str (lnrecno1) Additive

	tcOper =  'test'
	tcDok = 'test'
	tnId = 1
	tAeg = Gomonth(Datetime() , -4)

	If gversia = 'VFP'
		lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+;
			" VALUES ("+Str (grekv)+","+ Str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+Str( tnId)+","+;
			"datetime("+Str(Year(tAeg))+","+Str(Month(tAeg))+","+Str(Day(tAeg))+"))"
		&lcString
	Else
		If gversia= 'PG'
			lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+" VALUES ("+Str (grekv)+","+ Str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+Str( tnId)+", timestamp '" +Ttoc(tAeg)+"')"
		Else
			lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+;
				" VALUES ("+Str (grekv)+","+ Str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+Str( tnId)+",'" +Ttoc(tAeg)+"')"
		Endif
		lError = sqlexec (gnhandle,lcString)
		If lError < 1
			lcViga = 'Viga,lisamine raamat'
			Replace testlog.Log With lcViga Additive
			Messagebox (lcViga)
			Set Step On
			Return
		Endif
	Endif

	tAeg = Datetime()
	If gversia = 'VFP'
		lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+;
			" VALUES ("+Str (grekv)+","+ Str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+Str( tnId)+","+;
			"datetime("+Str(Year(tAeg))+","+Str(Month(tAeg))+","+Str(Day(tAeg))+"))"
		&lcString
	Else
		If gversia = 'PG'
			lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+;
				" VALUES ("+Str (grekv)+","+ Str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+Str( tnId)+", timestamp '" +Ttoc(tAeg)+"')"
		Else
			lcString = " INSERT INTO raamat (reKvid, usErid, opEratsioon, doKument, doKid, aeg) "+;
				" VALUES ("+Str (grekv)+","+ Str (guSerid)+",'"+ tcOper+"','"+ tcDok+"',"+Str( tnId)+",'" +Ttoc(tAeg)+"')"
		Endif
		lError = sqlexec (gnhandle,lcString)
		If lError < 1
			lcViga = 'Viga,lisamine raamat'
			Replace testlog.Log With lcViga Additive
			Messagebox (lcViga)
			Set Step On
			Return
		Endif
	Endif
	lnrecno2 = read_tbl()
	If Vartype (lnrecno2)= 'C'
		lnrecno2 = Val (Alltrim(lnrecno2))
	Endif
	Replace testlog.Log With '1 RECNO(RAAMAT):'+Str (lnrecno1) Additive
	If lnrecno1+2 <> lnrecno2
		lcViga = 'Viga,������ ���-�� ������� � �������'
		Replace testlog.Log With lcViga Additive
		Messagebox (lcViga)
	Endif
	If Empty (tlDebug)
		Set Step On
	Endif
	LRETURN = .Exec ('check_raamat_aeg')
	lnrecno3 = read_tbl()
	If Vartype (lnrecno3)= 'C'
		lnrecno3 = Val (Alltrim(lnrecno3))
	Endif
	If lnrecno1+1 <> lnrecno2
		lvViga = 'Viga,������ ���-�� ������� � �������'
		Replace testlog.Log With lcViga Additive
		Messagebox (lcViga)
	Endif

	If LRETURN = .T.
		Replace testlog.Log With 'FUNCTION CHECK_RAAMAT_AEG: OK' Additive
		Messagebox ('Ok')
	Else
		Replace testlog.Log With 'FUNCTION CHECK_RAAMAT_AEG: FAILD' Additive
		Messagebox ('FAILD')
	Endif
Endwith
If File('testlog.log')
	Copy Memo testlog.Log To testlog.Log Additive
Else
	Copy Memo testlog.Log To testlog.Log
Endif


*!*	lcDir = curdir ()
*!*	set default to 'c:\avpsoft\files\buh52\proc'
*!*	lnSumma = analise_formula (lcFormula, date())
*!*	set step on
*!*	set default to (lcDir)

