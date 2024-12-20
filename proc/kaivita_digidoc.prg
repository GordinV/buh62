PARAMETERS tPdffile
tPdfFile = IIF(EMPTY(tPdfFile),'',tPdfFile)
*=launch('c:\program files\DigiDoc\digidoc.exe ','c:\program files\DigiDoc\')
=launch('explore', JUSTPATH(tPdfFile),JUSTPATH(tPdfFile))


FUNCTION launch
LPARAMETERS cCommand, cFile, cStartPath
LOCAL nWhnd, nResult, cMsg
DECLARE INTEGER ShellExecute IN SHELL32 INTEGER hwnd, STRING cOP, STRING cFile, STRING cParams, STRING cStartDir, INTEGER nShowCmd
DECLARE INTEGER GetDesktopWindow IN User32
nWhnd = GetDesktopWindow()
*'Open'
nResult = ShellExecute(nWhnd, cCommand, cFile, tPdffile, cStartPath, 1)
cMsg = ''
if nResult > 1
	do CASE
	CASE nResult = 2     && File not found
		cMsg = 'File not found'
	CASE nResult = 3     && Path not found
		cMsg = 'Path not found'
	CASE nResult = 5     && Access denied
		cMsg = 'Access denied'
	CASE nResult = 8     && Not enough memory
		cMsg = 'Not enough memory to run'
	CASE nResult = 0x32  && DLL Not found
		cMsg = 'DLL missing'
	CASE nResult = 0x26  && Sharing violation
		cMsg = 'Sharing violation'
	CASE nResult = 0x27  && Invalid file association
		cMsg = 'Invalid file'
	CASE nResult = 0x28  && DDE Timeout
		cMsg = 'DDE Timeout'
	CASE nResult = 0x29  && DDE Fail
		cMsg = 'DDE Fail'
	CASE nResult = 0x30  && DDE Busy
		cMsg = 'DDE Busy'
	CASE nResult = 0x31  && No association
		cMsg = 'No application is associated with this file'
	CASE nResult = 0x11  && Invalid EXE format
		cMsg = 'Invalid EXE format'
	OTHERWISE
		cMsg = ''
	ENDCASE
	if !empty(cMsg)
		messagebox(cMsg,'Kontrol')
	endif
endif

return cMsg


ENDFUNC

