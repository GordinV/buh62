Parameters 	aCheckedFields, tcAlias

lnFields = Afields(laFields,tcAlias)

For i = 1 To Alen(aCheckedFields)
	lnElement = Ascan(laFields, aCheckedFields[i])

	If lnElement = 0
		Messagebox('test failed, puudub field ' + aCheckedFields[i],0 + 48,'Error')
		lError = .F.
		Exit
	Endif
Endfor

Return lError
