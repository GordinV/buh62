**
** calc_puhkuse_paevad.fxp
**
Parameter tnId, tdKpv1, tnTunnus, tnTyyp
Local lnPaevad, lnSunniaasta
lnPaevad = 0
If tnTunnus=1
	odB.Use('qryTooleping','tmpleping')
	Select coMasutusremote
	Locate For coMasutusremote.Id=tmPleping.paRentid
	If  .Not. Found() .Or. Reccount('tmpleping')=0
		Return 0
	Endif
	lnSunniaasta = Val('19'+Substr(coMasutusremote.reGkood, 2, 2))
	lnSunnikuu = Val(Substr(coMasutusremote.reGkood, 4, 2))
	lnSunnipaev = Val(Substr(coMasutusremote.reGkood, 6, 2))
	If (lnSunnikuu>0 .And. lnSunnikuu<=12) .And. (lnSunnipaev>0 .And.  ;
			lnSunnipaev<31) .And. (lnSunniaasta>Year(Date())-85 .And.  ;
			lnSunniaasta<Year(Date())-10)
		lnAasta = (Date()-Date(lnSunniaasta, lnSunnikuu, lnSunnipaev))/365
	Else
		lnAasta = 18
	Endif
	Do Case
		Case tmPleping.amEtnik=1 .And. tnTyyp=1
			lnPaevad = 35-puHkus_used()
		Case tmPleping.amEtnik=0 .And. lnAasta>=18 .And. tnTyyp=1
			lnPaevad = 28-puHkus_used()
		Case tmPleping.amEtnik=0 .And. lnAasta<18 .And. tnTyyp=1
			lnPaevad = 35-puHkus_used()
		Case tnTyyp=3
			lnPaevad = 3-puHkus_used()
	Endcase
	If (Date()-Ttod(tmPleping.alGab))<365 .And. tnTyyp=1
		lnKuu1 = Month(Ttod(tmPleping.alGab))
		lnKuu2 = Month(Date())
		If lnKuu1>lnKuu2
			lnKuu2 = lnKuu2+12
		Endif
		lnKuud = lnKuu2-lnKuu1
		lnPaevad = Ceiling(lnPaevad/12*lnKuud)
	Endif
	If Used('tmpleping')
		Use In tmPleping
	Endif
	lnPaevad = Iif(lnPaevad<0, 0, lnPaevad)
Endif
Return lnPaevad
Endfunc
*
Function puHkus_used
	Local lnPaevad
	lnPaevad = 0
	tnLeping1 = tnId
	tnLeping2 = tnId
	ldKpv = tdKpv1
	tdKpv1 = Date(Year(ldKpv), 1, 1)
	tdKpv2 = ldKpv
	odB.Use('qryPuudumine','tmpPuhkus')
	Select tmPpuhkus
	Locate For tuNnus=tnTunnus .And. tyYp=tnTyyp
	If Found()
		lnPaevad = tmPpuhkus.paEvad
	Endif
	Use In tmPpuhkus
	Return lnPaevad
Endfunc
*
