Close data all
grekv = 1
gVersia = 'VFP'
gnhandle = 1
glError = .f.
&&cData = 'c:\buh50\dbavpsoft\buhdata5.dbc'
cData = 'c:\dbaSE\buhdata5.dbc'
open data (cdata)
Use eelarve\menuitem IN 0
Use eelarve\menubar IN 0
Use config IN 0

Set classlib to classes\classlib
oDb = createobject('db')
oDb.login = 'VLAD'
oDb.pass = ''

Create cursor curKey (versia m)
Append blank
Replace versia with 'RAAMA' in curKey
Create cursor v_account (admin int default 1)

Create cursor fltrAruanne (kpv1 d default date (year (date()),month (date()),1),;
	kpv2 d default gomonth (fltrAruanne.kpv1,1) - 1,konto c(20), deebet c(20),;
	kreedit c(20), asutusId int, kood1 int, kood2 int,;
	kood3 int, kood4 int, tunnus int)

append blank
set step on
set procedure to proc\analise_formula
do queries\eelarve\bilanssaruanne_report1
set procedure to
if !empty (alias())
	brow
endif

report form reports\eelarve\bilanssandmik_report1 prev
if !used ('curPrinter')
	use curprinter in 0
endif
*!*	select curprinter
*!*	locate for 	procfail = 'bilanssaruanne_report1'
*!*	if !found ()
*!*		messagebox ('Viga, ei leida paring curprinter tabelis')
*!*	endif