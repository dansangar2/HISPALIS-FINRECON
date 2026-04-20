//FINRECON JOB (ACCT),'FINRECON DEMO',CLASS=A,MSGCLASS=X,NOTIFY=&SYSUID
//*------------------------------------------------------------------*
//* FINRECON - JCL DIDACTICO DE REFERENCIA                           *
//*------------------------------------------------------------------*
//* Este JCL es una version demostrativa para portfolio.             *
//* Muestra como se ejecutaria el batch FINRECON en un entorno host. *
//* Ajusta DSN, LOADLIB y parametros segun tu instalacion real.      *
//*------------------------------------------------------------------*
//STEP010  EXEC PGM=FINRECON
//STEPLIB  DD  DSN=HISPALIS.FINRECON.LOAD,
//             DISP=SHR
//SYSOUT   DD  SYSOUT=*
//SYSPRINT DD  SYSOUT=*
//*------------------------------------------------------------------*
//* ENTRADAS                                                         *
//*------------------------------------------------------------------*
//ACCOUNTS DD  DSN=HISPALIS.FINRECON.INPUT.ACCOUNTS,
//             DISP=SHR
//TRANS    DD  DSN=HISPALIS.FINRECON.INPUT.TRANS,
//             DISP=SHR
//*------------------------------------------------------------------*
//* SALIDAS                                                          *
//*------------------------------------------------------------------*
//RESULTS  DD  DSN=HISPALIS.FINRECON.OUTPUT.RESULTS,
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1),RLSE),
//             DCB=(RECFM=FB,LRECL=120,BLKSIZE=0)
//ERRORS   DD  DSN=HISPALIS.FINRECON.OUTPUT.ERRORS,
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1),RLSE),
//             DCB=(RECFM=FB,LRECL=120,BLKSIZE=0)
//REPORT   DD  DSN=HISPALIS.FINRECON.OUTPUT.REPORT,
//             DISP=(NEW,CATLG,DELETE),
//             SPACE=(TRK,(1,1),RLSE),
//             DCB=(RECFM=FB,LRECL=133,BLKSIZE=0)
//*------------------------------------------------------------------*
//* NOTAS DIDACTICAS                                                 *
//*------------------------------------------------------------------*
//* 1) PGM=FINRECON invoca el modulo batch ya compilado en LOADLIB.  *
//* 2) ACCOUNTS y TRANS son los ficheros de entrada del proceso.     *
//* 3) RESULTS, ERRORS y REPORT recogen las salidas del lote.        *
//* 4) En un entorno real, nombres DSN, DCB y SPACE pueden variar.   *
//*------------------------------------------------------------------*
