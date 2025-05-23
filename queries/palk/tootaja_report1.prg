Parameter cWhere
If isdigit(alltrim(cWhere))
	cWhere = val(alltrim(cWhere))
Endif
tnId = cWhere

lError = oDb.readFromModel('palk\tootaja', 'row', 'tnId, guserid', 'qryIsik')
lError = oDb.readFromModel('palk\tootaja', 'tooleping', 'tnId, guserid', 'qrytooleping')
lError = oDb.readFromModel('palk\tootaja', 'palk_kaart', 'tnId, guserid', 'qryPalkKaart')


Create cursor tootaja_report1 (isikukood c(20) ,;
	nimi c(254) , aadress c(254) ,;
	tel c(120) , faks c(120) ,;
	email c(254) , muud m ,;
	amet c(254) , osakond c(254) ,;
	algab d ,; 
	lopp d ,;
	palk y , ;
	tasuliik c(20) ,;
	toopaev int , palgamaar int ,;
	pohikoht c(20) ,;
	koormus int , ametnik c(20) ,;
	kood c(20),nimetus c(254),liik c(20), summa y, percent_ c(20), tulumaks c(20), objekt c(20),;
	tulumaar int, maks c(20))

Select qrytooleping
Scan
*!*		if reccount ('tootaja_report1') < 1
*!*			append blank
*!*		endif
	Select qryPalkKaart
	SCAN FOR qryPalkKaart.lepingid = qrytooleping.id
		Select tootaja_report1
		Append blank
		lcLiik = ''
		Do case
			Case qryPalkKaart.liik = 1
				lcLiik = 'Arvestused'
			Case qryPalkKaart.liik = 2
				lcLiik = 'Kinnipidamised'
			Case qryPalkKaart.liik = 3
				lcLiik = 'Muud'
			Case qryPalkKaart.liik = 4
				lcLiik = 'Tulumaks'
			Case qryPalkKaart.liik = 5
				lcLiik = 'Sotsialmaks'
			Case qryPalkKaart.liik = 6
				lcLiik = 'Väljamaksed'
		Endcase
		lcAadress = iif (empty (qryIsik.aadress),space(1),qryIsik.aadress)
		Replace isikukood with qryIsik.regkood,;
			nimi with qryIsik.nimetus, aadress with lcAadress,;
			tel with qryIsik.tel, faks with qryIsik.faks,;
			email with qryIsik.email,; 
			muud with iif (isnull(qryIsik.muud) or empty(qryIsik.muud) ,space(1),qryIsik.muud),;
			amet with qrytooleping.amet,;
			osakond with qrytooleping.osakond,;
			algab with qrytooleping.algab,; 
			lopp with iif (IIF(ISNULL(qrytooleping.lopp),{},qrytooleping.lopp) < qrytooleping.algab,{},qrytooleping.lopp),;
			palk with qrytooleping.palk, ;
			tasuliik with qrytooleping.tasu_liik,;
			toopaev with qrytooleping.toopaev, palgamaar with qrytooleping.palgamaar,;
			pohikoht with iif (qrytooleping.pohikoht = 1,'Jah','Ei'),;
			koormus with qrytooleping.koormus, ametnik with iif (qrytooleping.ametnik = 1,'Jah','Ei'),;
			kood with ALLTRIM(qryPalkKaart.kood),;
			nimetus with ALLTRIM(qryPalkKaart.nimetus),;
			objekt WITH ALLTRIM(qryPalkKaart.objekt),;
			liik with lcLiik,;
			summa with  qryPalkKaart.summa,;
			percent_ with iif (qryPalkKaart.percent_ = 1,'Jah','Ei'),;
			tulumaks with iif (qryPalkKaart.tulumaks = 1, 'Jah','Ei'),;
			tulumaar with qryPalkKaart.tulumaar,;
			maks with iif (qryPalkKaart.liik = 2,iif(qryPalkKaart.maks = 1,'Jah','Ei'),space(1)) in tootaja_report1

	Endscan
Endscan
Use in qryPalkKaart
Use in qryIsik
Use in qrytooleping
Select tootaja_report1
