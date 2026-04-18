      *===============================================================
      * OUTRESREC.CPY
      * Successful result record layout for RESULTS.DAT
      * Layout del registro de salida correcta para RESULTS.DAT
      *
      * Notes / Notas:
      * This copybook starts at level 05 because it is intended to be
      * included under a parent 01 record in the FD section.
      * Este copybook comienza en nivel 05 porque esta pensado para
      * incluirse bajo un registro 01 padre en la seccion FD.
      * It stores the functional trace of an applied transaction.
      * Almacena la traza funcional de una transaccion aplicada.
      *===============================================================
       05  RES-TRN-ID              PIC X(12).
       05  RES-ACCOUNT-IBAN        PIC X(24).
       05  RES-TYPE                PIC X(01).
       05  RES-AMOUNT              PIC 9(11)V99.
       05  RES-CURRENCY            PIC X(03).
       05  RES-NEW-BALANCE         PIC 9(11)V99.
       05  RES-STATUS              PIC X(10).
       05  RES-MESSAGE             PIC X(20).
