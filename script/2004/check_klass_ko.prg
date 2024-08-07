gnhandle = SQLConnect('narvalvpg', 'vlad','490710')
If gnhandle < 1
	Messagebox('Viga, uhendus')
	Return .F.
Endif

lcString = " select library.kood, palk_oper.* "+; 
" from palk_oper inner join curJournal on palk_oper.journalId = curJournal.id "+;
" inner join tooleping on palk_oper.lepingid = tooleping.id "+;
" inner join library on tooleping.osakondid = library.id "+;
" where palk_oper.rekvid = 13 "+;
" and LEFT(deebet,4) in ('5001','5002','5005') and kreedit = '202000' "+;
" and MONTH(palk_oper.kpv) = 6 "


lError = SQLEXEC(gnhandle,lcString,'qryPalkoper')
IF lError > 0
	lError = SQLEXEC(gnhandle,'begin work')

	SELECT qryPalkOper
	SCAN
		WAIT WINDOW STR(RECNO('qryPalkOper'))+'-'+STR(RECCOUNT('qryPalkOper')) nowait
		lcTegev = LEFT(TRIM(qryPalkOper.kood),5)
		lcString = " update journal1 set tunnus = '"+qryPalkOper.kood +"' where parentid = "+STR(qryPalkOper.journalid) +;
			" and parentid in (select id from journal where rekvid = 13 and MONTH(kpv) = 6) and EMPTY(journal1.tunnus)"

		lError = SQLEXEC(gnhandle,lcString)
		IF lError < 0
			exit
		ENDIF
	ENDSCAN
ENDIF


If lError > 0
	=SQLEXEC(gnhandle,'commit work')
	Messagebox('Ok')
Else
	SET STEP ON 
	=SQLEXEC(gnhandle,'rollback work')
	Messagebox('Viga')
Endif
=SQLDISCONNECT(gnhandle)
