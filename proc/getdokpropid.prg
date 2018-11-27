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
tnId = coMdokremote.Id

lcWhere = "dok = '" + Alltrim(tcTyyp) + "'"
lError = oDb.readFromModel('libs\libraries\dokprops', 'curDokprop', 'gRekv, guserid', 'curDokProp', lcWhere)

If Reccount('curDokProp')>1
	lcForm = 'validok'
	Do Form (lcForm) To lnId With tnId
Else
	If Reccount('curDokProp')<1
		Create Cursor cMessage (prOp1 Int)
		Insert Into cMessage (prOp1) Values (coMdokremote.Id)
		lcForm = 'dokprop'
		Do Form (lcForm) To lnId With 'ADD', 0
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
