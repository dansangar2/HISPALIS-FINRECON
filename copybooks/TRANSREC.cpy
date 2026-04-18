      *===============================================================
      * TRANSREC.CPY
      * Transaction input record layout for TRANS.DAT
      * Layout del registro de entrada de transacciones para TRANS.DAT
      *
      * Notes / Notas:
      * This copybook starts at level 05 because it is intended to be
      * included under a parent 01 record in the FD section.
      * Este copybook comienza en nivel 05 porque esta pensado para
      * incluirse bajo un registro 01 padre en la seccion FD.
      * The account identifier is modeled as a 24-character IBAN.
      * El identificador de cuenta se modela como un IBAN de 24
      * caracteres.
      * Transaction amount uses 2 implied decimal positions.
      * El importe de la transaccion usa 2 posiciones decimales
      * implicitas.
      *===============================================================
       05  TRN-ID                  PIC X(12).
       05  TRN-DATE                PIC 9(08).
       05  TRN-ACCOUNT-IBAN        PIC X(24).
       05  TRN-TYPE                PIC X(01).
       05  TRN-AMOUNT              PIC 9(11)V99.
       05  TRN-CURRENCY            PIC X(03).
       05  TRN-CHANNEL             PIC X(10).
       05  TRN-DESC                PIC X(20).
