Parameter cWhere
dKpv1 = Iif(!Empty(fltrAruanne.kpv1), fltrAruanne.kpv1,Date(Year(Date()),1,1))
dKpv2 = Iif(!Empty(fltrAruanne.kpv2), fltrAruanne.kpv2,Date())
Replace fltrAruanne.kpv1 With dKpv1,;
	fltrAruanne.kpv2 With dKpv2 In fltrAruanne


lcString = "select sp_varatulud_aruanne1("+STR(grekv)+", date("+STR(YEAR(dkpv1),4)+","+STR(MONTH(dkpv1),2)+","+;
	STR(DAY(dkpv1),2)+"), date("+STR(YEAR(dkpv2),4)+","+STR(MONTH(dkpv2),2)+","+STR(DAY(dkpv2),2)+"))"


IF SQLEXEC(gnhandle,lcString,'tmpAruanne') < 1
	MESSAGEBOX('Viga')
	SELECT 0
	return
ENDIF

SELECT tmpAruanne
lcTimestamp = ALLTRIM(tmpAruanne.sp_varatulud_aruanne1)

USE IN tmpAruanne

lcString = "select * from tmp_vara where rekvid = " + STR(grekv)+" and timestamp = '"+lcTimestamp +"' "+;
" order by art asc,tunnus asc, artikkel desc, tulusumma asc, panksumma asc, tasudsumma asc "


IF SQLEXEC(gnhandle,lcString,'varatulu_report1') < 1
	MESSAGEBOX('Viga')
	SELECT 0
	return
ENDIF


SELECT varatulu_report1


*!*			create cursor varatulu_report1 (art c(20), artikkel c(20), tunnus c(20), nimetus c(254), ;
*!*				 tulusumma n (14,2) default 0, 	panksumma n(14,2) default 0, tasudsumma n(14,2) default 0, jaak n(14,2) default 0)