# Layouts funcionales de ficheros

Este documento define los layouts funcionales de los ficheros de entrada y salida del proceso **FINRECON** con suficiente detalle para generar copybooks sin ambigüedad.

## Convenciones

- Las **posiciones** son **1-based** e inclusivas.
- Las **longitudes** están expresadas en caracteres.
- Los ficheros `*.DAT` están definidos en el programa como **LINE SEQUENTIAL** y se manejan como registros de longitud lógica fija.
- Los campos con `V99` tienen **decimales implícitos**: el separador decimal no forma parte del registro.
- Para soportar formatos realistas de banca, los identificadores de cuenta se modelan como **IBAN** de **24 posiciones**.
- La última actualización de cuenta se modela como **timestamp UTC en ISO 8601** (`YYYY-MM-DDThh:mm:ssZ`), porque una fecha sin hora ni zona no permite expresar UTC de forma útil.
- `REPORT.TXT` está definido como un área de impresión `PIC X(120)` y se escribe como **texto secuencial**; cada línea tiene una **longitud lógica máxima de 120** posiciones, aunque visualmente pueda verse más corta si termina en blancos.

---

## 1. ACCOUNTS.DAT

**Tipo:** fichero secuencial de entrada  
**Longitud lógica del registro:** **91**

### Layout

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 24 | 24 | ACCT-IBAN | X(24) | Identificador de cuenta en formato IBAN |
| 25 | 54 | 30 | ACCT-NAME | X(30) | Nombre o descripción de la cuenta |
| 55 | 55 | 1 | ACCT-STATUS | X(01) | Estado de la cuenta. Valores observados: `A` = activa, `B` = bloqueada |
| 56 | 58 | 3 | ACCT-CURRENCY | X(03) | Divisa ISO de la cuenta |
| 59 | 71 | 13 | ACCT-BALANCE | 9(11)V99 | Saldo actual con 2 decimales implícitos |
| 72 | 91 | 20 | ACCT-LAST-UPD-UTC | X(20) | Timestamp UTC en formato ISO 8601 `YYYY-MM-DDThh:mm:ssZ` |

### Ejemplo de registro

```text
ES9121000418450200051332OPERATIVA PRINCIPAL           AEUR00000001500002026-04-01T08:15:30Z
```

### Propuesta de copybook

```cobol
01 ACCOUNTS-RECORD.
   05 ACCT-IBAN            PIC X(24).
   05 ACCT-NAME            PIC X(30).
   05 ACCT-STATUS          PIC X(01).
   05 ACCT-CURRENCY        PIC X(03).
   05 ACCT-BALANCE         PIC 9(11)V99.
   05 ACCT-LAST-UPD-UTC    PIC X(20).
```

---

## 2. TRANS.DAT

**Tipo:** fichero secuencial de entrada  
**Longitud lógica del registro:** **91**

### Layout

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 12 | 12 | TRN-ID | X(12) | Identificador único de transacción |
| 13 | 20 | 8 | TRN-DATE | 9(08) | Fecha de transacción en formato `YYYYMMDD` |
| 21 | 44 | 24 | TRN-ACCOUNT-IBAN | X(24) | IBAN de la cuenta afectada |
| 45 | 45 | 1 | TRN-TYPE | X(01) | Tipo de operación. Valores válidos en proceso: `D` = débito, `C` = crédito |
| 46 | 58 | 13 | TRN-AMOUNT | 9(11)V99 | Importe con 2 decimales implícitos |
| 59 | 61 | 3 | TRN-CURRENCY | X(03) | Divisa ISO de la transacción |
| 62 | 71 | 10 | TRN-CHANNEL | X(10) | Canal de entrada o captura |
| 72 | 91 | 20 | TRN-DESC | X(20) | Descripción funcional de la transacción |

### Ejemplo de registro

```text
TRX00000000120260415ES9121000418450200051332D0000000025000EURATM       PAGO PROVEEDOR      
```

### Propuesta de copybook

```cobol
01 TRANS-RECORD.
   05 TRN-ID               PIC X(12).
   05 TRN-DATE             PIC 9(08).
   05 TRN-ACCOUNT-IBAN     PIC X(24).
   05 TRN-TYPE             PIC X(01).
   05 TRN-AMOUNT           PIC 9(11)V99.
   05 TRN-CURRENCY         PIC X(03).
   05 TRN-CHANNEL          PIC X(10).
   05 TRN-DESC             PIC X(20).
```

---

## 3. RESULTS.DAT

**Tipo:** fichero secuencial de salida  
**Longitud lógica del registro:** **96**

### Layout

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 12 | 12 | RES-TRN-ID | X(12) | Identificador de transacción procesada |
| 13 | 36 | 24 | RES-ACCOUNT-IBAN | X(24) | IBAN de la cuenta afectada |
| 37 | 37 | 1 | RES-TYPE | X(01) | Tipo de operación aplicada |
| 38 | 50 | 13 | RES-AMOUNT | 9(11)V99 | Importe aplicado |
| 51 | 53 | 3 | RES-CURRENCY | X(03) | Divisa de la operación |
| 54 | 66 | 13 | RES-NEW-BALANCE | 9(11)V99 | Nuevo saldo de la cuenta tras aplicar la transacción |
| 67 | 76 | 10 | RES-STATUS | X(10) | Estado funcional del resultado. En los ejemplos: `APLICADA` más relleno a blancos |
| 77 | 96 | 20 | RES-MESSAGE | X(20) | Mensaje funcional. En los ejemplos: `OPERACION OK` más relleno a blancos |

### Ejemplo de registro

```text
TRX000000001ES9121000418450200051332D0000000025000EUR0000000125000APLICADA  OPERACION OK        
```

### Propuesta de copybook

```cobol
01 RESULTS-RECORD.
   05 RES-TRN-ID           PIC X(12).
   05 RES-ACCOUNT-IBAN     PIC X(24).
   05 RES-TYPE             PIC X(01).
   05 RES-AMOUNT           PIC 9(11)V99.
   05 RES-CURRENCY         PIC X(03).
   05 RES-NEW-BALANCE      PIC 9(11)V99.
   05 RES-STATUS           PIC X(10).
   05 RES-MESSAGE          PIC X(20).
```

---

## 4. ERRORS.DAT

**Tipo:** fichero secuencial de salida  
**Longitud lógica del registro:** **94**

### Layout

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 12 | 12 | ERR-TRN-ID | X(12) | Identificador de la transacción rechazada |
| 13 | 36 | 24 | ERR-ACCOUNT-IBAN | X(24) | IBAN informado en la transacción |
| 37 | 40 | 4 | ERR-CODE | X(04) | Código de error funcional |
| 41 | 41 | 1 | ERR-SEVERITY | X(01) | Severidad del error. En el programa se informa `F` |
| 42 | 54 | 13 | ERR-AMOUNT | 9(11)V99 | Importe original de la transacción |
| 55 | 94 | 40 | ERR-MESSAGE | X(40) | Texto descriptivo del error |

### Ejemplo de registro

```text
TRX000000003ES3021000418401234567891E102F0000000005000CUENTA BLOQUEADA                        
```

### Propuesta de copybook

```cobol
01 ERRORS-RECORD.
   05 ERR-TRN-ID           PIC X(12).
   05 ERR-ACCOUNT-IBAN     PIC X(24).
   05 ERR-CODE             PIC X(04).
   05 ERR-SEVERITY         PIC X(01).
   05 ERR-AMOUNT           PIC 9(11)V99.
   05 ERR-MESSAGE          PIC X(40).
```

---

## 5. REPORT.TXT

**Tipo:** fichero secuencial de texto / print file  
**Área lógica de escritura:** **120** posiciones (`PIC X(120)`)  
**Estructura funcional:** fichero de líneas heterogéneas, no un único registro de datos repetitivo.

### Criterio de modelado

Para tratamiento técnico, el fichero puede modelarse con la siguiente definición base:

```cobol
01 REPORT-LINE             PIC X(120).
```

No obstante, para evitar ambigüedad funcional, se documentan a continuación los distintos **tipos de línea** que genera el programa.

### Secuencia de líneas generadas

1. Línea separadora
2. Título del informe
3. Fecha de proceso
4. Hora de proceso
5. Cuentas cargadas
6. Transacciones leídas
7. Transacciones correctas
8. Transacciones erróneas
9. Total debitado
10. Total acreditado
11. Return code
12. Línea separadora

---

### 5.1 Línea separadora

**Longitud lógica:** **120**

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 120 | 120 | REP-SEPARATOR | X(120) | Línea compuesta por guiones `-` |

**Ejemplo:**

```text
------------------------------------------------------------------------------------------------------------------------
```

---

### 5.2 Línea de título

**Longitud lógica:** **120**

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 40 | 40 | REP-TITLE | X(40) | Literal `HISPALIS FINRECON - RESUMEN DE EJECUCION` |
| 41 | 120 | 80 | FILLER | X(80) | Blancos |

**Ejemplo:**

```text
HISPALIS FINRECON - RESUMEN DE EJECUCION
```

---

### 5.3 Línea de fecha de proceso

**Longitud lógica:** **120**

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 19 | 19 | REP-LABEL | X(19) | Literal `FECHA PROCESO    : ` |
| 20 | 27 | 8 | WS-PROCESS-DATE | 9(08) | Fecha del proceso en formato `YYYYMMDD` |
| 28 | 120 | 93 | FILLER | X(93) | Blancos |

**Ejemplo:**

```text
FECHA PROCESO    : YYYYMMDD
```

---

### 5.4 Línea de hora de proceso

**Longitud lógica:** **120**

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 19 | 19 | REP-LABEL | X(19) | Literal `HORA PROCESO     : ` |
| 20 | 27 | 8 | WS-PROCESS-TIME | 9(08) | Hora del proceso en formato `HHMMSSCC` |
| 28 | 120 | 93 | FILLER | X(93) | Blancos |

**Ejemplo:**

```text
HORA PROCESO     : HHMMSSCC
```

---

### 5.5 Línea de cuentas cargadas

**Longitud lógica:** **120**

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 19 | 19 | REP-LABEL | X(19) | Literal `CUENTAS CARGADAS : ` |
| 20 | 26 | 7 | ED-COUNT | ZZZZZZ9 | Contador editado, alineado a la derecha |
| 27 | 120 | 94 | FILLER | X(94) | Blancos |

**Ejemplo:**

```text
CUENTAS CARGADAS :       4
```

---

### 5.6 Línea de transacciones leídas

**Longitud lógica:** **120**

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 19 | 19 | REP-LABEL | X(19) | Literal `TRANS LEIDAS     : ` |
| 20 | 26 | 7 | ED-COUNT | ZZZZZZ9 | Contador editado |
| 27 | 120 | 94 | FILLER | X(94) | Blancos |

**Ejemplo:**

```text
TRANS LEIDAS     :       9
```

---

### 5.7 Línea de transacciones correctas

**Longitud lógica:** **120**

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 19 | 19 | REP-LABEL | X(19) | Literal `TRANS OK         : ` |
| 20 | 26 | 7 | ED-COUNT | ZZZZZZ9 | Contador editado |
| 27 | 120 | 94 | FILLER | X(94) | Blancos |

**Ejemplo:**

```text
TRANS OK         :       3
```

---

### 5.8 Línea de transacciones erróneas

**Longitud lógica:** **120**

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 19 | 19 | REP-LABEL | X(19) | Literal `TRANS ERROR      : ` |
| 20 | 26 | 7 | ED-COUNT | ZZZZZZ9 | Contador editado |
| 27 | 120 | 94 | FILLER | X(94) | Blancos |

**Ejemplo:**

```text
TRANS ERROR      :       6
```

---

### 5.9 Línea de total debitado

**Longitud lógica:** **120**

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 19 | 19 | REP-LABEL | X(19) | Literal `TOTAL DEBITADO   : ` |
| 20 | 33 | 14 | ED-AMOUNT | ZZZZZZZZZ99.99 | Importe editado con punto decimal explícito |
| 34 | 120 | 87 | FILLER | X(87) | Blancos |

**Ejemplo:**

```text
TOTAL DEBITADO   : 00000000375.75
```

---

### 5.10 Línea de total acreditado

**Longitud lógica:** **120**

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 19 | 19 | REP-LABEL | X(19) | Literal `TOTAL ACREDITADO : ` |
| 20 | 33 | 14 | ED-AMOUNT | ZZZZZZZZZ99.99 | Importe editado con punto decimal explícito |
| 34 | 120 | 87 | FILLER | X(87) | Blancos |

**Ejemplo:**

```text
TOTAL ACREDITADO : 00000001200.00
```

---

### 5.11 Línea de return code

**Longitud lógica:** **120**

| Pos. ini | Pos. fin | Long. | Campo | PIC | Descripción |
|---:|---:|---:|---|---|---|
| 1 | 19 | 19 | REP-LABEL | X(19) | Literal `RETURN CODE      : ` |
| 20 | 26 | 7 | ED-COUNT | ZZZZZZ9 | Código de retorno editado |
| 27 | 120 | 94 | FILLER | X(94) | Blancos |

**Ejemplo:**

```text
RETURN CODE      :       0
```

---

## Resumen de longitudes

| Fichero | Longitud lógica |
|---|---:|
| ACCOUNTS.DAT | 91 |
| TRANS.DAT | 91 |
| RESULTS.DAT | 96 |
| ERRORS.DAT | 94 |
| REPORT.TXT | 120 por línea lógica de impresión |
