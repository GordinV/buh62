Close data all
grekv = 3	
gVersia = 'MSSQL'
gnhandle = sqlconnect ('narva','vladislav','654')
glError = .f.
*!*	Use menuitem IN 0
*!*	Use menubar IN 0
Use config IN 0

Set classlib to classes\classlib
oDb = createobject('db')
oDb.login = 'VLADISLAV	'
oDb.pass = '654'

Create cursor curKey (versia m)
Append blank
Replace versia with 'POHIVARA' in curKey
Create cursor v_account (admin int default 1)


append blank
with odb
	tcKood = '%'
	tcNimetus = '%'
	tcKonto = '%'
	tcVastIsik = '%'
	tcGrupp = 'INVENT%'
	tnSoetmaks1 = 0
	tnSoetmaks2 = 999999999
	tdSoetkpv1 = DATE(1900,1,1)
	tdSoetkpv2 = DATE(1998,12,31)
	tnTunnus = 1
	.USE ('CURPOHIVARA')
	.use ('v_pv_oper','v_pv_oper',.t.)
	.opentransaction()
	select curpohivara
	brow
	scan
		wait window [Arvestan .. ] + curpohivara.kood nowait
		tnId = curPohivara.id
		tnLiik = 2
		.use ('v_pv_oper','qryPvOper')
		select qryPvOper
		sum summa to lnsumma
		if curpohivara.soetmaks - lnSumma > 0
			insert into v_pv_oper (parentid, nomid,liik, kpv, summa) values; 
				(curpohivara.id, 214, 2,date(2002,12,31), curpohivara.soetmaks - lnSumma)
		endif
	endscan
	select v_pv_oper
	brow
	wait window [Salvesta .. ] nowait
	lError = .cursorupdate ('v_pv_oper')
	set step on
	if lError = .f.
		.rollback()
		messagebox ('Viga')
	else
		.commit()
		messagebox ('Ok')
	endif
endwith
=sqldisconnect (gnhandle)
