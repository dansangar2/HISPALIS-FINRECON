//FINRECON JOB (ACCT),'FINRECON',CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//* -----------------------------------------------------------------*
//*  HISPALIS-FINRECON - EJEMPLO DIDACTICO DE EJECUCION BATCH
//*  Este JCL es de referencia para portfolio.
//*  En una adaptación real sobre z/OS, el programa usaría DDNAMEs
//*  en lugar de rutas de sistema de ficheros.
//* -----------------------------------------------------------------*
//STEP01   EXEC PGM=FINRECON,REGION=0M
//STEPLIB  DD  DSN=HISPALIS.COBOL.LOADLIB,DISP=SHR
//SYSOUT   DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//ACCIN    DD  DSN=HISPALIS.FINRECON.ACCOUNTS,DISP=SHR
//TRNIN    DD  DSN=HISPALIS.FINRECON.TRANS,DISP=SHR
//RESOUT   DD  DSN=HISPALIS.FINRECON.RESULTS(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(1,1),RLSE),
//             DCB=(RECFM=FB,LRECL=82,BLKSIZE=0)
//ERROUT   DD  DSN=HISPALIS.FINRECON.ERRORS(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(1,1),RLSE),
//             DCB=(RECFM=FB,LRECL=80,BLKSIZE=0)
//RPTOUT   DD  DSN=HISPALIS.FINRECON.REPORT(+1),
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(CYL,(1,1),RLSE),
//             DCB=(RECFM=FB,LRECL=120,BLKSIZE=0)
