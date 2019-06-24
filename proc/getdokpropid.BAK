Lparameter tcTyyp, tcModel
Local lnId
lnId = 0
If !Used('comDokRemote') Or Reccount('comDokRemote') = 0
	lError = oDb.readFromModel('libs\libraries\dokprops', 'selectAsLibs', 'gRekv, guserid', 'comDokRemote')
Endif

Select coMdokremote
Locate For Alltrim(Upper(koOd))=Alltrim(Upper(tcTyyp))
If  .Not. Found()
	Return 0
Endif

lcWhere = "dok = '" + Alltrim(tcTyyp) + "'"
lError = oDb.readFromModel('libs\libraries\dokprops', 'curDokprop', 'gRekv, guserid', 'curDokProp', lcWhere)

If Reccount('curDokProp') > 1
	Do Form validok To lnId With coMdokremote.Id
Else
	If Reccount('curDokProp')<1
		Create Cursor cMessage (prOp1 Int)
		Insert Into cMessage (prOp1) Values (coMdokremote.Id)
		Do Form dokprop To lnId With 'ADD', 0
	Else
		lnId = cuRdokprop.Id
	Endif
Endif
If Used('curDokprop')
	Use In cuRdokprop
Endif
Return lnId
Endfunc
*
