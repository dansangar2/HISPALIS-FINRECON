# Layouts de ficheros

## 1. ACCOUNTS.DAT

Registro de longitud fija: **65 bytes**

| Posición | Longitud | Campo | PIC | Descripción |
|---|---:|---|---|---|
| 1 | 10 | ACCT-ID | X(10) | Identificador de cuenta |
| 11 | 30 | ACCT-NAME | X(30) | Descripción de la cuenta |
| 41 | 1 | ACCT-STATUS | X(1) | `A` Activa / `B` Bloqueada |
| 42 | 3 | ACCT-CURRENCY | X(3) | Divisa ISO (`EUR`, `USD`) |
| 45 | 13 | ACCT-BALANCE | 9(11)V99 | Saldo con 2 decimales implícitos |
| 58 | 8 | ACCT-LAST-UPD | 9(8) | Fecha `YYYYMMDD` |

Ejemplo:

```text
0000001001OPERATIVA PRINCIPAL           AEUR000000015000020260401
```

## 2. TRANS.DAT

Registro de longitud fija: **77 bytes**

| Posición | Longitud | Campo | PIC | Descripción |
|---|---:|---|---|---|
| 1 | 12 | TRN-ID | X(12) | Identificador de transacción |
| 13 | 8 | TRN-DATE | 9(8) | Fecha `YYYYMMDD` |
| 21 | 10 | TRN-ACCOUNT-ID | X(10) | Cuenta objetivo |
| 31 | 1 | TRN-TYPE | X(1) | `D` débito / `C` crédito |
| 32 | 13 | TRN-AMOUNT | 9(11)V99 | Importe con 2 decimales implícitos |
| 45 | 3 | TRN-CURRENCY | X(3) | Divisa ISO |
| 48 | 10 | TRN-CHANNEL | X(10) | Canal (`ATM`, `WEB`, `SWIFT`, etc.) |
| 58 | 20 | TRN-DESC | X(20) | Descripción funcional |

Ejemplo:

```text
TRX000000001202604150000001001D0000000025000EURATM       PAGO PROVEEDOR      
```

## 3. RESULTS.DAT

Registro de longitud fija: **82 bytes**

| Posición | Longitud | Campo | PIC | Descripción |
|---|---:|---|---|---|
| 1 | 12 | RES-TRN-ID | X(12) | Transacción procesada |
| 13 | 10 | RES-ACCOUNT-ID | X(10) | Cuenta afectada |
| 23 | 1 | RES-TYPE | X(1) | Tipo de operación |
| 24 | 13 | RES-AMOUNT | 9(11)V99 | Importe |
| 37 | 3 | RES-CURRENCY | X(3) | Divisa |
| 40 | 13 | RES-NEW-BALANCE | 9(11)V99 | Nuevo saldo |
| 53 | 10 | RES-STATUS | X(10) | Estado (`APLICADA`) |
| 63 | 20 | RES-MESSAGE | X(20) | Mensaje de negocio |

## 4. ERRORS.DAT

Registro de longitud fija: **80 bytes**

| Posición | Longitud | Campo | PIC | Descripción |
|---|---:|---|---|---|
| 1 | 12 | ERR-TRN-ID | X(12) | Transacción rechazada |
| 13 | 10 | ERR-ACCOUNT-ID | X(10) | Cuenta informada |
| 23 | 4 | ERR-CODE | X(4) | Código de error |
| 27 | 1 | ERR-SEVERITY | X(1) | Severidad (`F` funcional / `T` técnica) |
| 28 | 13 | ERR-AMOUNT | 9(11)V99 | Importe original |
| 41 | 40 | ERR-MESSAGE | X(40) | Descripción del error |

## 5. REPORT.TXT

Fichero secuencial de texto con:

- fecha y hora de proceso
- número de cuentas cargadas
- número de transacciones leídas
- operaciones aplicadas
- operaciones rechazadas
- total debitado
- total acreditado
- código de retorno
