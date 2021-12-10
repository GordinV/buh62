
close all
IF FILE("xfrx.app")
   SET PROCEDURE TO ("xfrx.app") ADDITIVE
ENDIF
local loSession, lnRetval
loSession=EVALUATE([xfrx("XFRX#INIT")])
loSession.addXLSFormatConversion("@L 999999.9999","000000.0000")
lnRetVal = loSession.SetParams("xlSample.xls",,,,,,"XLS")
If lnRetVal = 0
   loSession.ProcessReport("demoreps\xlsample")
   loSession.finalize()
Endif