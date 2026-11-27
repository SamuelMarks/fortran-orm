C @file fortran_orm_f77.inc
C @brief ANSI X3.9-1978 FORTRAN 77 6-character PARAMETER constants.
C
C Every symbolic constant is strictly <= 6 uppercase characters with
C zero underscores so strict ANSI FORTRAN 77 compilers accept this file
C via INCLUDE or copy-in without extensions.
      INTEGER CORMOK, CMEMER, CCNNER, CSQLER, CBNDER, CSTPER
      INTEGER CTYPER, CNTFND, CVALER, CNULPT, CCONER, CTIMER
      INTEGER CTRUNC, CHNDER, CFULER, CBUFER, CIDXER, COPCER
      INTEGER CDSQLT, CDPG, CDMY, CDDB2, CDODBC
      PARAMETER (CORMOK = 0, CMEMER = 1, CCNNER = 2, CSQLER = 3)
      PARAMETER (CBNDER = 4, CSTPER = 5, CTYPER = 6, CNTFND = 7)
      PARAMETER (CVALER = 11, CNULPT = 14, CCONER = 21, CTIMER = 24)
      PARAMETER (CTRUNC = 26, CHNDER = 32, CFULER = 33, CBUFER = 34)
      PARAMETER (CIDXER = 35, COPCER = 36)
      PARAMETER (CDSQLT = 0, CDPG = 1, CDMY = 2, CDDB2 = 3, CDODBC = 4)
