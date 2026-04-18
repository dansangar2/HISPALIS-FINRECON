# Casos de prueba incluidos

## Dataset base

El fichero `data/TRANS.DAT` incluye 9 transacciones:

| Caso | Descripción | Resultado esperado |
|---|---|---|
| 1 | Débito válido sobre cuenta activa EUR | OK |
| 2 | Crédito válido sobre cuenta activa EUR | OK |
| 3 | Débito sobre cuenta bloqueada | E102 |
| 4 | Débito sobre cuenta inexistente | E101 |
| 5 | Débito con saldo insuficiente | E103 |
| 6 | Crédito con divisa incorrecta | E106 |
| 7 | Tipo de operación inválido | E104 |
| 8 | Importe igual a cero | E105 |
| 9 | Débito válido sobre cuenta USD | OK |

## Contadores esperados

- cuentas cargadas: **4**
- transacciones leídas: **9**
- operaciones aplicadas: **3**
- operaciones rechazadas: **6**
- total debitado: **375.75**
- total acreditado: **1200.00**
- return code esperado: **0**

## Archivos de referencia

- `output/RESULTS_EXPECTED.DAT`
- `output/ERRORS_EXPECTED.DAT`
- `output/REPORT_EXPECTED.TXT`
