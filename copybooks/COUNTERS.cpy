      *===============================================================
      * COUNTERS.CPY
      * Batch counters and financial accumulators
      * Contadores batch y acumulados financieros
      *
      * Notes / Notas:
      * This copybook starts at level 05 because it is intended to be
      * included under a parent 01 area in WORKING-STORAGE.
      * Este copybook comienza en nivel 05 porque esta pensado para
      * incluirse bajo un area 01 padre en WORKING-STORAGE.
      * Counters are unsigned display numerics for easy reporting.
      * Los contadores son numericos display sin signo para facilitar
      * su impresion en el informe.
      * Monetary accumulators keep 2 implied decimal positions.
      * Los acumulados monetarios mantienen 2 posiciones decimales
      * implicitas.
      *===============================================================
       05  CNT-ACCOUNTS-READ       PIC 9(7) VALUE ZERO.
       05  CNT-TRANS-READ          PIC 9(7) VALUE ZERO.
       05  CNT-TRANS-OK            PIC 9(7) VALUE ZERO.
       05  CNT-TRANS-ERR           PIC 9(7) VALUE ZERO.
       05  AMT-DEBIT-TOTAL         PIC 9(13)V99 VALUE ZERO.
       05  AMT-CREDIT-TOTAL        PIC 9(13)V99 VALUE ZERO.
