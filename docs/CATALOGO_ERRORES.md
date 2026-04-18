# Catálogo de errores

## Errores funcionales

| Código | Severidad | Descripción | Regla de disparo |
|---|---|---|---|
| E101 | F | Cuenta no existe | No se encuentra `TRN-ACCOUNT-ID` en maestro de cuentas |
| E102 | F | Cuenta bloqueada | `ACCT-STATUS <> 'A'` |
| E103 | F | Saldo insuficiente | Débito con saldo menor al importe |
| E104 | F | Tipo de operación inválido | `TRN-TYPE` distinto de `D` o `C` |
| E105 | F | Importe no válido | `TRN-AMOUNT <= 0` |
| E106 | F | Divisa no coincide | `TRN-CURRENCY <> ACCT-CURRENCY` |

## Errores técnicos

| Código | Severidad | Descripción | Situación |
|---|---|---|---|
| E901 | T | Error técnico de apertura | Fallo al abrir ficheros |
| E902 | T | Tabla de cuentas llena | Se supera el máximo OCCURS cargable |
| E903 | T | Error técnico de lectura | `FILE STATUS` anómalo en lectura |
| E904 | T | Error técnico de escritura | `FILE STATUS` anómalo en escritura |

## Convenciones de tratamiento

- los errores funcionales se registran en `ERRORS.DAT` y el proceso continúa
- los errores técnicos son fatales y finalizan el lote con código de retorno distinto de cero
- el `REPORT.TXT` debe reflejar contadores y totales finales
