      *===============================================================
      * ERRREC.CPY
      * Error output record layout for ERRORS.DAT
      * Layout del registro de salida de errores para ERRORS.DAT
      *
      * Notes / Notas:
      * This copybook starts at level 05 because it is intended to be
      * included under a parent 01 record in the FD section.
      * Este copybook comienza en nivel 05 porque esta pensado para
      * incluirse bajo un registro 01 padre en la seccion FD.
      * Severity is kept as a one-character code so the same record can
      * register both functional and technical issues.
      * La severidad se mantiene como un codigo de un caracter para que
      * el mismo registro pueda reflejar errores funcionales y tecnicos.
      *===============================================================
       05  ERR-TRN-ID              PIC X(12).
       05  ERR-ACCOUNT-IBAN        PIC X(24).
       05  ERR-CODE                PIC X(04).
       05  ERR-SEVERITY            PIC X(01).
       05  ERR-AMOUNT              PIC 9(11)V99.
       05  ERR-MESSAGE             PIC X(40).
