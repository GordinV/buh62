IF USED('curPrinter')
	USE IN curPrinter
ENDIF

Create Cursor curprinter (Id Int, objekt c(40), nimetus1 c(120), nimetus2 c(120), procfail c(120), reportfail c(120),;
	reportvene c(120), Parameter m)

cFile = 'EELARVE\curPrinter.DBF'
If File (cFile)
	Use (cFile) In 0 Alias curPrinter0
Else
	Use curprinter In 0 Alias curPrinter0
Endif

Select curprinter
Append From Dbf('curPrinter0')

Use In curPrinter0

cFile1 = 'ERI\curPrinter.DBF'
If File (cFile1)
	Use (cFile1) In 0 Alias curPrinter4
	Select curprinter
	Append From Dbf('curPrinter4')
	Use In curPrinter4
Endif
