# HISPALIS-FINRECON

Proyecto de **conciliación financiera batch en COBOL** preparado para portfolio técnico y entrevistas.  
La idea no es solo “hacer una práctica”, sino mostrar señales de trabajo real en entornos legacy:

- procesamiento batch con múltiples ficheros
- validación funcional y técnica
- salidas diferenciadas (`RESULTS.DAT`, `ERRORS.DAT`, `REPORT.TXT`)
- manejo estructurado de errores
- código modular con copybooks
- juego de datos de prueba
- referencia de JCL
- propuesta de evolución a DB2

## 1. Qué demuestra este proyecto

Este proyecto está pensado para que un reclutador o responsable técnico vea rápidamente que sabes moverte en un flujo COBOL batch:

- lectura y cruce de ficheros
- control de reglas de negocio
- validación de registros
- tratamiento de errores funcionales y técnicos
- generación de outputs de proceso
- diseño modular y mantenible

## 2. Estructura del repositorio

```text
HISPALIS_FINRECON_portfolio/
├── README.md
├── src/
│   └── FINRECON.cbl
├── copybooks/
│   ├── ACCNTREC.cpy
│   ├── TRANSREC.cpy
│   ├── OUTRESREC.cpy
│   ├── ERRREC.cpy
│   └── COUNTERS.cpy
├── data/
│   ├── ACCOUNTS.DAT
│   └── TRANS.DAT
├── output/
│   ├── RESULTS_EXPECTED.DAT
│   ├── ERRORS_EXPECTED.DAT
│   └── REPORT_EXPECTED.TXT
├── jcl/
│   └── FINRECON.jcl
├── docs/
│   ├── FILE_LAYOUTS.md
│   ├── CATALOGO_ERRORES.md
│   └── DB2_EXTENSION.sql
├── tests/
│   └── CASOS_PRUEBA.md
└── scripts/
    └── run_gnucobol.sh
```

## 3. Flujo funcional

Entradas:

- `ACCOUNTS.DAT`: maestro de cuentas
- `TRANS.DAT`: transacciones a conciliar

Proceso:

1. carga del maestro de cuentas en memoria
2. lectura secuencial de transacciones
3. búsqueda de cuenta asociada
4. validación funcional
5. aplicación de la operación si es válida
6. escritura en `RESULTS.DAT` o `ERRORS.DAT`
7. generación de `REPORT.TXT` con estadísticas de ejecución

Salidas:

- `RESULTS.DAT`: operaciones aplicadas correctamente
- `ERRORS.DAT`: registros rechazados con código de error
- `REPORT.TXT`: resumen del lote

## 4. Reglas de negocio implementadas

- la cuenta debe existir
- la cuenta debe estar activa (`A`)
- el tipo de operación debe ser `D` (debit) o `C` (credit)
- el importe debe ser mayor que cero
- la divisa de la transacción debe coincidir con la de la cuenta
- en operaciones de débito debe existir saldo suficiente

## 5. Catálogo de errores principal

| Código | Descripción |
|---|---|
| E101 | Cuenta no existe |
| E102 | Cuenta bloqueada |
| E103 | Saldo insuficiente |
| E104 | Tipo de operación inválido |
| E105 | Importe no válido |
| E106 | Divisa no coincide |
| E901 | Error técnico de apertura |
| E902 | Tabla de cuentas llena |
| E903 | Error técnico de lectura |
| E904 | Error técnico de escritura |

## 6. Cómo compilar y ejecutar con GnuCOBOL

Requisitos:

- GnuCOBOL instalado (`cobc`)
- ejecución desde la raíz del proyecto

Comando rápido:

```bash
bash scripts/run_gnucobol.sh
```

Comando manual:

```bash
cobc -x -free -I copybooks -o output/bin/FINRECON src/FINRECON.cbl
./output/bin/FINRECON
```

## 7. Datos de prueba incluidos

El proyecto trae un dataset con casos válidos y erróneos:

- débito correcto
- crédito correcto
- cuenta bloqueada
- cuenta inexistente
- saldo insuficiente
- divisa incorrecta
- tipo de operación inválido
- importe cero

En `output/` se incluyen resultados esperados de referencia.

## 8. Valor de portfolio / CV

Puedes describirlo en el currículum así:

> **Proyecto COBOL Batch – Conciliación Financiera**
> Desarrollo de proceso batch en COBOL para conciliación de transacciones contra cuentas, con validaciones funcionales, gestión estructurada de errores, outputs diferenciados, reporting y diseño modular basado en copybooks.

## 9. Evolución enterprise sugerida

Este proyecto está preparado para crecer hacia un escenario más parecido a banca/seguros:

- sustitución de `ACCOUNTS.DAT` por tabla DB2
- auditoría persistente en base de datos
- JCL real de ejecución y scheduling
- particionado por lotes
- control de restart/reprocess
- integración con APIs o colas
- adaptación futura a CICS para consulta online

La propuesta de tablas DB2 está en `docs/DB2_EXTENSION.sql`.

## 10. Qué conviene enseñar en entrevista

- el flujo batch de extremo a extremo
- cómo separas error funcional de error técnico
- cómo documentaste layouts y reglas
- cómo estructuraste el programa por párrafos
- cómo lo llevarías de fichero plano a DB2/JCL real
