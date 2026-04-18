      *===============================================================
      * ACCNTREC.CPY
      * Account master record layout for ACCOUNTS.DAT
      * Layout del registro maestro de cuentas para ACCOUNTS.DAT
      *
      * Notes / Notas:
      * This copybook starts at level 05 because it is intended to be
      * included under a parent 01 record in the FD section.
      * Este copybook comienza en nivel 05 porque esta pensado para
      * incluirse bajo un registro 01 padre en la seccion FD.
      * The account identifier is modeled as a 24-character IBAN.
      * El identificador de cuenta se modela como un IBAN de 24
      * caracteres.
      * The last update field is stored as an ISO 8601 UTC timestamp.
      * El campo de ultima actualizacion se almacena como timestamp
      * UTC en formato ISO 8601.
      *===============================================================
       05  ACCT-IBAN               PIC X(24).
       05  ACCT-NAME               PIC X(30).
       05  ACCT-STATUS             PIC X(01).
       05  ACCT-CURRENCY           PIC X(03).
       05  ACCT-BALANCE            PIC 9(11)V99.
       05  ACCT-LAST-UPD-UTC       PIC X(20).
