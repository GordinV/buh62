Parameter tnIsikId, tdKpv
Local l_test

If Empty(tdKpv)
	tdKpv = Date()
ENDIF

gdKpv = tdKpv

* period
TEXT TO l_where NOSHOW textmerge
	aasta = <<YEAR(gdKpv)>>
	and kuu = <<MONTH(gdKpv)>>
ENDTEXT


lError = oDb.readFromModel('ou\aasta', 'selectAsLibs', 'gRekv', 'tmp_period', l_where )
If !lError Or !Used('tmp_period')
	Messagebox('Viga',0+16, 'Period')
	Set Step On
	Return .T.
Endif

If Reccount('tmp_period') > 0 And !Empty(tmp_period.kinni)
	Messagebox('Period on kinni',0+16,'Kontrol')
	Return .F.
Endif

If Used('tmp_period')
	Use In tmp_period
Endif

Local lnResult

With oDb

	If Empty(tnIsikId)
		tnIsikId= 0
	Endif

	If  .Not. Used('curSource')
		Create Cursor curSource (Id Int, koOd c (20), niMetus c (120))
	Endif
	If  .Not. Used('curValitud')
		Create Cursor curValitud (Id Int, koOd c (20), niMetus c (120))
	Endif
	Create Cursor curResult (Id Int, Isik Int)

	lnStep = 1
	Do While lnStep>0
		If  .Not. Empty(tnIsikId)
			Insert Into curResult (Id, Isik) Values (tnIsikId, 1)

			tnId = tnIsikId
			Select curResult
		Endif
		Do Case
			Case lnStep=1
				Do geT_isikute_list
			Case lnStep>3
				Do arVutus
		Endcase
	Enddo
	If Used('curSource')
		Use In curSource
	Endif
	If Used('curvalitud')
		Use In curValitud
	Endif
	If Used('curResult')
		Use In curResult
	Endif
Endwith
Endproc
*
Procedure arVutus
	Local lError
	WAIT windows 'Arvestan taskuraha...' NOWAIT 

	Select Distinct Id From curResult Where Isik=1 Into Cursor recalc1
	l_params_id = ''
	Scan
		If Len(l_params_id) > 0
			l_params_id = l_params_id + ','
		Endif
		l_params_id = l_params_id  + ALLTRIM(Str(recalc1.Id))
	ENDSCAN

	
	lError = oDb.readFromModel('hooldekodu\hooisik', 'koostaHooVorder', 'l_params_id,guserid,gdKpv', 'v_tulemus')
	IF !lError
		MESSAGEBOX('Error',0+16, 'Taabelite arvestus')
		SET STEP ON 
	ENDIF
	WAIT windows 'Arvestan taabelid...Ok' TIMEOUT 1	
		
	lnStep = 0
Endproc


Procedure geT_isikute_list
	If Used('query1')
		Use In query1
	Endif

	lError = oDb.readFromModel('hooldekodu\hooisik', 'selectAsLibs', 'gRekv', 'tmpIsikud')
	IF !lError 
		MESSAGEBOX('Viga',0+16,'Isikute nimekiri')
		
	ENDIF
	
	SELECT DISTINCT id, isikukood as kood, nimi as nimetus ;
		FROM tmpIsikud ;
		WHERE (EMPTY(gdKpv) OR loppkpv >= gdKpv);		
		and makse_viis = 2; 				
		ORDER BY nimi;
		INTO CURSOR qryIsikud
	USE IN tmpIsikud 

	Select curSource
	If Reccount('curSource')>0
		Zap
	ENDIF
	
	Append From Dbf('qryIsikud')
	Use In qryIsikud

	Select curValitud
	If Reccount('curvalitud')>0
		Zap
	Endif
	Do Form Forms\samm To nrEsult With '2', Iif(coNfig.keEl=2, 'Isikud',  ;
		'Услуги'), Iif(coNfig.keEl=2, 'Valitud isikud', 'Выбранные услуги') , gdKpv
	If nrEsult=1

		Select Distinct Id From curValitud Where  Not Id In(Select Id From  ;
			curResult Where isik=1) Into Cursor query1
		Select query1
		Scan
			Insert Into curResult (Id, isik) Values (query1.Id, 1)
		Endscan
		Use In query1
		Select curValitud
		Zap
	Endif
	If nrEsult=0
		lnStep = 0
	Else
		lnStep = 4
	Endif
Endproc

