# Términos básicos de banca y conciliación

Este fichero reúne términos que en proyectos bancarios o financieros aparecen con frecuencia, pero que no siempre son comunes en el día a día. La idea es dejar un glosario rápido para entrevistas, documentación funcional y lectura del código.

## Glosario

| Término | Significado sencillo | Ejemplo |
|---|---|---|
| Abono | Movimiento que incrementa el saldo de una cuenta. En muchos contextos equivale a un crédito. | “Se registró un abono de nómina de 1.200,00 EUR.” |
| Apunte | Registro individual de un movimiento contable o bancario. | “Cada transferencia genera un apunte.” |
| Acreditado | Importe que ha sido sumado a una cuenta. | “El dinero quedó acreditado en la cuenta destino.” |
| Cargo | Movimiento que reduce el saldo de una cuenta. | “El recibo se procesó como un cargo.” |
| Conciliación | Proceso de comparar y cuadrar movimientos entre dos fuentes para detectar diferencias. | “El batch reconcilia transacciones contra el maestro de cuentas.” |
| Contrapartida | La otra parte de una operación financiera o contable. | “En una transferencia, la contrapartida es la cuenta opuesta.” |
| Débito | Operación que descuenta dinero de una cuenta. | “Un débito válido reduce el saldo disponible.” |
| Debitador / Debitado | Importe o cuenta a la que se le ha cargado dinero. | “El total debitado del lote fue 375,75.” |
| Devengo | Momento en que un ingreso o gasto se reconoce contablemente, aunque no se haya cobrado o pagado aún. | “El interés se reconoce por devengo.” |
| Divisa | Moneda de una cuenta u operación. | “La divisa de la transacción es EUR.” |
| Fecha valor | Fecha a partir de la cual un movimiento produce efectos económicos, no siempre coincide con la fecha de operación. | “La transferencia se ordenó hoy, pero con fecha valor mañana.” |
| IBAN | Identificador internacional de cuenta bancaria. En España tiene 24 caracteres. | “El proyecto usa IBAN de 24 posiciones para los identificadores de cuenta.” |
| Importe | Cuantía monetaria de una operación. | “El importe debe ser mayor que cero.” |
| Liquidación | Cálculo y cierre económico de operaciones de un periodo o proceso. | “El sistema genera una liquidación diaria.” |
| Lote / Batch | Conjunto de registros procesados de forma masiva en una ejecución. | “El report resume el lote nocturno.” |
| Maestro de cuentas | Fichero o tabla principal con la información base de las cuentas. | “ACCOUNTS.DAT actúa como maestro de cuentas.” |
| Movimiento | Operación que altera el saldo o el estado de una cuenta. | “Cada transacción válida genera un movimiento.” |
| Saldo | Dinero acumulado disponible o contabilizado en una cuenta. | “La cuenta tenía saldo suficiente.” |
| Saldo insuficiente | Situación en la que una cuenta no tiene fondos para soportar un débito. | “La transacción fue rechazada por saldo insuficiente.” |
| Timestamp UTC | Fecha y hora expresadas en tiempo universal coordinado. | “La última actualización se guarda como `2026-04-01T08:15:30Z`.” |
| Trazabilidad | Capacidad de seguir una operación desde su origen hasta su resultado final. | “El ID de transacción mejora la trazabilidad.” |
| Validación funcional | Comprobación de reglas de negocio. | “Que la cuenta esté activa es una validación funcional.” |
| Validación técnica | Comprobación de errores de lectura, escritura, apertura o formato técnico. | “Un error de apertura del fichero es técnico, no funcional.” |
| Valor disponible | Parte del saldo que realmente puede usarse en ese momento. | “No siempre coincide con el saldo contable.” |

## Nota rápida sobre algunos términos cercanos

- **Débito** y **cargo** suelen usarse muy cerca entre sí; ambos implican restar saldo, aunque el contexto operativo puede variar.
- **Crédito**, **abono** y **acreditado** también están muy relacionados; todos apuntan a sumar saldo.
- **Fecha de operación**, **fecha contable** y **fecha valor** no siempre significan lo mismo.
