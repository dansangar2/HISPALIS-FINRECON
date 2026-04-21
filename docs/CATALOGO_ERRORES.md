# Catálogo de errores · HISPALIS-FINRECON

## 1. Objetivo

Este documento define el catálogo de errores funcionales y técnicos del proceso batch **FINRECON**. Su finalidad es unificar los códigos utilizados por el programa COBOL, `ERRORS.DAT`, `REPORT.TXT` y la futura trazabilidad enterprise.

## 2. Criterios de codificación

- **Serie E1xx**: errores **funcionales**. La transacción se rechaza, se registra en `ERRORS.DAT` y el batch **continúa**.
- **Serie E9xx**: errores **técnicos o de control**. Se registra la incidencia y el batch puede quedar en **KO** o **KO-CONTROLADO** según el punto de fallo.
- **Severidad ALTA**: rechazo de transacción sin parada global.
- **Severidad CRÍTICA**: riesgo operativo o inconsistencia técnica; puede provocar aborto controlado del proceso.
- Cada incidencia debe registrar, como mínimo, `RUN-ID`, `TRX-ID`, `ACCOUNT-ID`, `ERROR-CODE`, `ERROR-TYPE`, `ERROR-SEVERITY`, `ERROR-DESC` y, cuando aplique, `RAW-RECORD`.

## 3. Relación con la lógica COBOL

Este catálogo está alineado con la estructura batch propuesta para `FINRECON`:

- `1000-INITIALIZE`: validación de parámetros y estado inicial.
- `1100-OPEN-FILES`: apertura de ficheros y validación de `FILE STATUS`.
- `2000-LOAD-ACCOUNTS`: carga o validación del maestro de cuentas.
- `3100-VALIDATE-TRANS`: reglas funcionales y validaciones de formato por registro.
- `3400-WRITE-ERROR`: emisión de incidencias en `ERRORS.DAT`.
- `5000-WRITE-REPORT`: consolidación de contadores y control de cierre.

## 4. Catálogo de errores funcionales

| Código | Tipo | Severidad | Descripción | Regla de disparo |
|---|---|---:|---|---|
| E101 | Funcional | ALTA | Cuenta inexistente | Se informa un `ACCOUNT-ID` no presente en `ACCOUNTS.DAT`. Corresponde a la regla **R01**. |
| E102 | Funcional | ALTA | Cuenta no operativa | La cuenta existe pero su `STATUS` es distinto de `A` (por ejemplo `B` bloqueada o `C` cerrada). Corresponde a **R02**. |
| E103 | Funcional | ALTA | Tipo de operación no admitido | El campo `OP-TYPE` no contiene un valor permitido (`C` crédito o `D` débito). Corresponde a **R03**. |
| E104 | Funcional | ALTA | Importe inválido | El campo `AMOUNT` no es numérico, es cero o es menor que cero. Corresponde a **R04**. |
| E105 | Funcional | ALTA | Divisa incompatible | La `CURRENCY` de la transacción no coincide con la `CURRENCY` de la cuenta. Corresponde a **R05**. |
| E106 | Funcional | ALTA | Saldo o disponible insuficiente | Para una operación de débito, el importe supera el disponible autorizado según saldo, límite de crédito y política de negativos. Corresponde a **R06**. |
| E107 | Funcional | ALTA | Transacción duplicada en la corrida | El `TRX-ID` ya fue procesado dentro del mismo `RUN-ID`. Corresponde a **R07**. |
| E108 | Funcional | ALTA | Fecha de operación inválida | `OP-DATE` no es una fecha válida o es posterior a `PROCESS-DATE`. Corresponde a **R08**. |

### Tratamiento estándar de errores funcionales

1. Rechazar la transacción actual.
2. Informar el código en `ERRORS.DAT`.
3. Incrementar el contador de rechazadas funcionales.
4. Continuar con la siguiente transacción.

## 5. Catálogo de errores técnicos y de control

| Código | Tipo | Severidad | Descripción | Situación técnica de disparo |
|---|---|---:|---|---|
| E901 | Técnico | CRÍTICA | Registro mal formado o layout inválido | Longitud incorrecta, campos obligatorios ausentes, contenido imposible de interpretar o desajuste con el layout esperado del fichero de entrada. Se usa cuando el registro no puede validarse con seguridad. |
| E902 | Técnico | CRÍTICA | Recurso de entrada no disponible o maestro inconsistente | Falta un fichero de entrada, no puede abrirse, `ACCOUNTS.DAT` está vacío o el maestro no es utilizable para el proceso. Suele dispararse en apertura o en carga inicial. |
| E903 | Técnico | CRÍTICA | Error de lectura o escritura | Se produce un `FILE STATUS` no esperado en operaciones de `READ`, `WRITE`, `REWRITE` o `CLOSE`, distinto de los valores controlados de operación normal o fin de fichero. |
| E904 | Control | CRÍTICA | Parámetro inválido o descuadre de cierre | `RUN-ID` ausente, `PROCESS-DATE` inválida, parámetros incoherentes, o descuadre entre contadores, importes y resumen final del batch. |

### Tratamiento estándar de errores técnicos

- **E901**: registrar incidencia, aumentar contador técnico y evaluar continuidad. Si el fallo afecta a un único registro, el batch puede continuar; si el defecto es estructural, cerrar en `KO-CONTROLADO`.
- **E902**: abortar el batch con cierre controlado, informar el recurso afectado y dejar evidencia en `REPORT.TXT`.
- **E903**: abortar el batch con detalle del `FILE STATUS` y del fichero implicado.
- **E904**: abortar antes del procesamiento o cerrar en `KO`, según el momento del hallazgo.

## 6. Correspondencia con el catálogo legado

Para mantener compatibilidad documental con la especificación anterior, la numeración enterprise se normaliza así:

| Catálogo legado | Catálogo enterprise | Observación |
|---|---|---|
| E001 | E101 | Cuenta inexistente |
| E002 | E102 | Cuenta bloqueada o cerrada |
| E003 | E103 | Tipo de operación no admitido |
| E004 | E104 | Importe nulo, negativo o no numérico |
| E005 | E105 | Divisa incompatible |
| E006 | E106 | Saldo o disponible insuficiente |
| E007 | E107 | Transacción duplicada |
| E008 | E108 | Fecha inválida o posterior a proceso |
| E009 | E901 | Registro mal formado |
| E010 / E011 | E902 | Maestro inconsistente o fichero no disponible |
| E012 | E903 | Error de lectura o escritura |
| E013 / E014 | E904 | Parámetro inválido o descuadre de control |

## 7. Reglas de uso en `ERRORS.DAT`

Cada registro de error debe conservar trazabilidad suficiente para auditoría y soporte:

- `RUN-ID`: corrida en la que se detectó la incidencia.
- `TRX-ID`: transacción asociada, si existe.
- `ACCOUNT-ID`: cuenta asociada, si existe.
- `ERROR-CODE`: valor del catálogo (`E101`...`E904`).
- `ERROR-TYPE`: `FUNCIONAL`, `TECNICO` o `CONTROL`.
- `ERROR-SEVERITY`: `ALTA` o `CRITICA`.
- `ERROR-DESC`: descripción corta normalizada.
- `RAW-RECORD`: contenido bruto recibido cuando ayude al diagnóstico.

## 8. Relación recomendada con `FILE STATUS`

| File status | Interpretación | Código recomendado |
|---|---|---|
| 00 | Operación correcta | No aplica |
| 10 | Fin de fichero | No aplica |
| 35 | Fichero no localizado en apertura | E902 |
| 39 | Desajuste entre definición y fichero | E901 |
| Otro valor no previsto | Incidencia técnica de E/S | E903 |

## 9. Criterio de severidad y estado final del batch

| Severidad | Impacto | Estado posible |
|---|---|---|
| ALTA | Rechazo de la transacción, sin parada global | `OK` o `OK-CON-RECHAZOS` |
| CRÍTICA | Riesgo técnico, inconsistencia o imposibilidad operativa | `KO` o `KO-CONTROLADO` |

## 10. Notas de implantación

- Este catálogo deja preparada la evolución enterprise sin romper la semántica funcional del MVP documentado.
- La serie `E1xx` separa claramente los rechazos de negocio de la serie `E9xx`, reservada para incidencias técnicas y de control.
- No requiere cambio funcional obligatorio sobre la lógica descrita; basta con alinear las constantes y la documentación del programa COBOL con esta numeración.

