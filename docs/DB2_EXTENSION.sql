-- ================================================================
-- HISPALIS-FINRECON
-- Fase 9 · Paso 42
-- Extensión enterprise futura con DB2
-- ================================================================
-- Objetivo
--   Diseñar una evolución del proyecto para sustituir el maestro de
--   cuentas en fichero (ACCOUNTS.DAT) por tablas DB2, manteniendo el
--   batch COBOL como proceso principal y sin reescribir aún el flujo
--   completo de conciliación.
--
-- Alcance de esta extensión
--   1) Reemplazar ACCOUNTS.DAT por FR_ACCOUNT_MASTER.
--   2) Añadir tablas de auditoría y trazabilidad del batch.
--   3) Mantener TRANS.DAT / RESULTS.DAT / ERRORS.DAT como artefactos
--      operativos mientras se acomete la migración de forma progresiva.
--
-- Estrategia recomendada
--   - Fase 1: Batch sigue leyendo TRANS.DAT y consulta DB2 para cuentas.
--   - Fase 2: Batch actualiza saldo en DB2 y persiste auditoría.
--   - Fase 3: Salidas file-based pasan a ser opcionales o de respaldo.
-- ================================================================

-- ================================================================
-- 1. MODELO MÍNIMO DE TABLAS
-- ================================================================

-- ------------------------------------------------
-- 1.1 Maestro de cuentas (sustituye ACCOUNTS.DAT)
-- ------------------------------------------------
CREATE TABLE FR_ACCOUNT_MASTER (
    ACCOUNT_ID           CHAR(10)       NOT NULL,
    CUSTOMER_ID          CHAR(12)       NOT NULL,
    STATUS               CHAR(1)        NOT NULL,
    CURRENT_BALANCE      DECIMAL(13,2)  NOT NULL DEFAULT 0.00,
    CREDIT_LIMIT         DECIMAL(13,2)  NOT NULL DEFAULT 0.00,
    CURRENCY             CHAR(3)        NOT NULL,
    LAST_MOV_DATE        DATE,
    CREATED_TS           TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
    LAST_UPD_TS          TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
    LAST_UPD_RUN_ID      CHAR(14),
    CONSTRAINT PK_FR_ACCOUNT_MASTER
        PRIMARY KEY (ACCOUNT_ID),
    CONSTRAINT CK_FR_ACCOUNT_STATUS
        CHECK (STATUS IN ('A', 'B', 'C')),
    CONSTRAINT CK_FR_ACCOUNT_CURRENCY
        CHECK (CURRENCY IN ('EUR', 'USD', 'GBP')),
    CONSTRAINT CK_FR_ACCOUNT_BALANCE
        CHECK (CURRENT_BALANCE >= -99999999999.99),
    CONSTRAINT CK_FR_ACCOUNT_LIMIT
        CHECK (CREDIT_LIMIT >= 0)
);

CREATE INDEX IX_FR_ACCOUNT_MASTER_01
    ON FR_ACCOUNT_MASTER (CUSTOMER_ID);

CREATE INDEX IX_FR_ACCOUNT_MASTER_02
    ON FR_ACCOUNT_MASTER (STATUS, CURRENCY);

-- Notas de negocio:
--   STATUS = 'A' activa, 'B' bloqueada, 'C' cerrada.
--   Disponible teórico para débito:
--      CURRENT_BALANCE + CREDIT_LIMIT
--   La política ALLOW-NEGATIVE del batch puede seguir existiendo en
--   CONTROL.DAT o migrarse más adelante a tabla de parámetros.


-- ----------------------------------------------
-- 1.2 Cabecera de ejecución del batch / corrida
-- ----------------------------------------------
CREATE TABLE FR_BATCH_RUN (
    RUN_ID               CHAR(14)       NOT NULL,
    PROCESS_DATE         DATE           NOT NULL,
    START_TS             TIMESTAMP      NOT NULL,
    END_TS               TIMESTAMP,
    BATCH_STATUS         VARCHAR(20)    NOT NULL,
    STRICT_MODE          CHAR(1)        NOT NULL DEFAULT 'N',
    ALLOW_NEGATIVE       CHAR(1)        NOT NULL DEFAULT 'N',
    OPERATOR_ID          CHAR(8),
    INPUT_COUNT          INTEGER        NOT NULL DEFAULT 0,
    SUCCESS_COUNT        INTEGER        NOT NULL DEFAULT 0,
    FUNC_ERROR_COUNT     INTEGER        NOT NULL DEFAULT 0,
    TECH_ERROR_COUNT     INTEGER        NOT NULL DEFAULT 0,
    TOTAL_CREDIT_AMOUNT  DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    TOTAL_DEBIT_AMOUNT   DECIMAL(15,2)  NOT NULL DEFAULT 0.00,
    RETURN_CODE          SMALLINT       NOT NULL DEFAULT 0,
    CONSTRAINT PK_FR_BATCH_RUN
        PRIMARY KEY (RUN_ID),
    CONSTRAINT CK_FR_BATCH_STATUS
        CHECK (BATCH_STATUS IN ('STARTED', 'OK', 'KO', 'KO-CONTROLADO')),
    CONSTRAINT CK_FR_BATCH_STRICT
        CHECK (STRICT_MODE IN ('Y', 'N')),
    CONSTRAINT CK_FR_BATCH_NEGATIVE
        CHECK (ALLOW_NEGATIVE IN ('Y', 'N'))
);

CREATE INDEX IX_FR_BATCH_RUN_01
    ON FR_BATCH_RUN (PROCESS_DATE, BATCH_STATUS);


-- --------------------------------------------------------
-- 1.3 Resultado de conciliación de movimientos aceptados
-- --------------------------------------------------------
CREATE TABLE FR_RECON_RESULT (
    RUN_ID               CHAR(14)       NOT NULL,
    TRX_ID               CHAR(12)       NOT NULL,
    ACCOUNT_ID           CHAR(10)       NOT NULL,
    OP_TYPE              CHAR(1)        NOT NULL,
    APPLIED_AMOUNT       DECIMAL(13,2)  NOT NULL,
    PREV_BALANCE         DECIMAL(13,2)  NOT NULL,
    NEW_BALANCE          DECIMAL(13,2)  NOT NULL,
    CURRENCY             CHAR(3)        NOT NULL,
    OP_DATE              DATE           NOT NULL,
    SOURCE_SYSTEM        VARCHAR(10)    NOT NULL,
    RESULT_CODE          CHAR(4)        NOT NULL DEFAULT 'OK00',
    CREATED_TS           TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
    CONSTRAINT PK_FR_RECON_RESULT
        PRIMARY KEY (RUN_ID, TRX_ID),
    CONSTRAINT FK_FR_RECON_RUN
        FOREIGN KEY (RUN_ID)
        REFERENCES FR_BATCH_RUN (RUN_ID),
    CONSTRAINT FK_FR_RECON_ACCOUNT
        FOREIGN KEY (ACCOUNT_ID)
        REFERENCES FR_ACCOUNT_MASTER (ACCOUNT_ID),
    CONSTRAINT CK_FR_RECON_OPTYPE
        CHECK (OP_TYPE IN ('C', 'D')),
    CONSTRAINT CK_FR_RECON_AMOUNT
        CHECK (APPLIED_AMOUNT > 0)
);

CREATE INDEX IX_FR_RECON_RESULT_01
    ON FR_RECON_RESULT (ACCOUNT_ID, OP_DATE);

CREATE INDEX IX_FR_RECON_RESULT_02
    ON FR_RECON_RESULT (SOURCE_SYSTEM, OP_DATE);


-- ---------------------------------------------------
-- 1.4 Registro de errores funcionales y técnicos
-- ---------------------------------------------------
CREATE TABLE FR_ERROR_LOG (
    ERROR_LOG_ID         BIGINT         NOT NULL
                                       GENERATED ALWAYS AS IDENTITY,
    RUN_ID               CHAR(14)       NOT NULL,
    TRX_ID               CHAR(12),
    ACCOUNT_ID           CHAR(10),
    ERROR_CODE           CHAR(4)        NOT NULL,
    ERROR_FAMILY         VARCHAR(12)    NOT NULL,
    ERROR_DESC           VARCHAR(120)   NOT NULL,
    RAW_RECORD           VARCHAR(300),
    FILE_STATUS          CHAR(2),
    TECH_CONTEXT         VARCHAR(120),
    CREATED_TS           TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
    CONSTRAINT PK_FR_ERROR_LOG
        PRIMARY KEY (ERROR_LOG_ID),
    CONSTRAINT FK_FR_ERROR_RUN
        FOREIGN KEY (RUN_ID)
        REFERENCES FR_BATCH_RUN (RUN_ID),
    CONSTRAINT CK_FR_ERROR_FAMILY
        CHECK (ERROR_FAMILY IN ('FUNCIONAL', 'TECNICO', 'CONTROL'))
);

CREATE INDEX IX_FR_ERROR_LOG_01
    ON FR_ERROR_LOG (RUN_ID, ERROR_CODE);

CREATE INDEX IX_FR_ERROR_LOG_02
    ON FR_ERROR_LOG (ACCOUNT_ID, CREATED_TS);


-- ---------------------------------------------------
-- 1.5 Parámetros de control (opcional, fase futura)
-- ---------------------------------------------------
CREATE TABLE FR_CTRL_PARAM (
    PARAM_NAME           VARCHAR(40)    NOT NULL,
    PARAM_VALUE          VARCHAR(120)   NOT NULL,
    EFFECTIVE_DATE       DATE           NOT NULL,
    END_DATE             DATE,
    IS_ACTIVE            CHAR(1)        NOT NULL DEFAULT 'Y',
    CREATED_TS           TIMESTAMP      NOT NULL DEFAULT CURRENT TIMESTAMP,
    CONSTRAINT PK_FR_CTRL_PARAM
        PRIMARY KEY (PARAM_NAME, EFFECTIVE_DATE),
    CONSTRAINT CK_FR_CTRL_PARAM_ACTIVE
        CHECK (IS_ACTIVE IN ('Y', 'N'))
);

CREATE INDEX IX_FR_CTRL_PARAM_01
    ON FR_CTRL_PARAM (PARAM_NAME, IS_ACTIVE, EFFECTIVE_DATE);


-- ================================================================
-- 2. CLAVES Y DECISIONES DE DISEÑO
-- ================================================================
-- FR_ACCOUNT_MASTER
--   PK: ACCOUNT_ID
--   Justificación: la cuenta es la clave natural del maestro.
--
-- FR_BATCH_RUN
--   PK: RUN_ID
--   Justificación: cada corrida debe ser auditable de forma unívoca.
--
-- FR_RECON_RESULT
--   PK: (RUN_ID, TRX_ID)
--   Justificación: evita duplicidad de transacción dentro de la corrida,
--   alineado con la regla funcional de no reprocesar el mismo TRX-ID.
--
-- FR_ERROR_LOG
--   PK técnica: ERROR_LOG_ID identity
--   Justificación: permite registrar errores incluso cuando TRX_ID o
--   ACCOUNT_ID vengan vacíos o mal formados.
--
-- FR_CTRL_PARAM
--   PK: (PARAM_NAME, EFFECTIVE_DATE)
--   Justificación: permite parametría versionada por vigencia.


-- ================================================================
-- 3. EJEMPLOS DE SQL PARA EL BATCH COBOL (SIN REESCRITURA COMPLETA)
-- ================================================================
-- Los ejemplos siguientes muestran cómo evolucionar la lógica actual del
-- batch para consultar DB2 en lugar de leer ACCOUNTS.DAT. Son referencias
-- de diseño; no implican todavía reescritura del programa completo.

-- -------------------------------------------------------------
-- 3.1 Alta de cabecera de corrida al arrancar el batch
-- -------------------------------------------------------------
INSERT INTO FR_BATCH_RUN (
    RUN_ID,
    PROCESS_DATE,
    START_TS,
    BATCH_STATUS,
    STRICT_MODE,
    ALLOW_NEGATIVE,
    OPERATOR_ID
)
VALUES (
    :WS-RUN-ID,
    :WS-PROCESS-DATE,
    CURRENT TIMESTAMP,
    'STARTED',
    :WS-STRICT-MODE,
    :WS-ALLOW-NEGATIVE,
    :WS-OPERATOR-ID
);


-- -----------------------------------------------------------------
-- 3.2 Consulta de cuenta para validación funcional y posible update
-- -----------------------------------------------------------------
SELECT ACCOUNT_ID,
       STATUS,
       CURRENT_BALANCE,
       CREDIT_LIMIT,
       CURRENCY,
       LAST_MOV_DATE
  INTO :HV-ACCOUNT-ID,
       :HV-ACCOUNT-STATUS,
       :HV-CURRENT-BALANCE,
       :HV-CREDIT-LIMIT,
       :HV-CURRENCY,
       :HV-LAST-MOV-DATE
  FROM FR_ACCOUNT_MASTER
 WHERE ACCOUNT_ID = :HV-IN-ACCOUNT-ID
 FOR READ ONLY;

-- Uso esperado desde COBOL:
--   SQLCODE = 0     -> cuenta encontrada
--   SQLCODE = 100   -> cuenta inexistente => error funcional E101
--   SQLCODE < 0     -> incidencia técnica DB2 => error técnico E901/E902


-- ------------------------------------------------------
-- 3.3 Validación de disponible para una operación débito
-- ------------------------------------------------------
SELECT CURRENT_BALANCE,
       CREDIT_LIMIT,
       (CURRENT_BALANCE + CREDIT_LIMIT) AS AVAILABLE_AMOUNT
  INTO :HV-CURRENT-BALANCE,
       :HV-CREDIT-LIMIT,
       :HV-AVAILABLE-AMOUNT
  FROM FR_ACCOUNT_MASTER
 WHERE ACCOUNT_ID = :HV-IN-ACCOUNT-ID
   AND STATUS = 'A'
 FOR READ ONLY;

-- Regla de decisión en COBOL:
--   Si HV-AVAILABLE-AMOUNT < HV-TRX-AMOUNT => error funcional E106.


-- --------------------------------------------------------------
-- 3.4 Bloqueo y actualización de saldo para movimientos aceptados
-- --------------------------------------------------------------
SELECT CURRENT_BALANCE
  INTO :HV-PREV-BALANCE
  FROM FR_ACCOUNT_MASTER
 WHERE ACCOUNT_ID = :HV-IN-ACCOUNT-ID
 FOR UPDATE OF CURRENT_BALANCE, LAST_MOV_DATE, LAST_UPD_TS, LAST_UPD_RUN_ID;

UPDATE FR_ACCOUNT_MASTER
   SET CURRENT_BALANCE = :HV-NEW-BALANCE,
       LAST_MOV_DATE   = :HV-OP-DATE,
       LAST_UPD_TS     = CURRENT TIMESTAMP,
       LAST_UPD_RUN_ID = :WS-RUN-ID
 WHERE ACCOUNT_ID = :HV-IN-ACCOUNT-ID;

-- Nota:
--   El control de COMMIT puede mantenerse por bloque de registros para no
--   degradar rendimiento batch. La granularidad final dependerá del volumen.


-- -----------------------------------------------------
-- 3.5 Persistencia de movimientos conciliados en DB2
-- -----------------------------------------------------
INSERT INTO FR_RECON_RESULT (
    RUN_ID,
    TRX_ID,
    ACCOUNT_ID,
    OP_TYPE,
    APPLIED_AMOUNT,
    PREV_BALANCE,
    NEW_BALANCE,
    CURRENCY,
    OP_DATE,
    SOURCE_SYSTEM,
    RESULT_CODE
)
VALUES (
    :WS-RUN-ID,
    :HV-TRX-ID,
    :HV-IN-ACCOUNT-ID,
    :HV-OP-TYPE,
    :HV-TRX-AMOUNT,
    :HV-PREV-BALANCE,
    :HV-NEW-BALANCE,
    :HV-TRX-CURRENCY,
    :HV-OP-DATE,
    :HV-SOURCE-SYSTEM,
    'OK00'
);


-- -------------------------------------------------------
-- 3.6 Registro de errores funcionales o técnicos en DB2
-- -------------------------------------------------------
INSERT INTO FR_ERROR_LOG (
    RUN_ID,
    TRX_ID,
    ACCOUNT_ID,
    ERROR_CODE,
    ERROR_FAMILY,
    ERROR_DESC,
    RAW_RECORD,
    FILE_STATUS,
    TECH_CONTEXT
)
VALUES (
    :WS-RUN-ID,
    :HV-TRX-ID,
    :HV-IN-ACCOUNT-ID,
    :WS-ERROR-CODE,
    :WS-ERROR-FAMILY,
    :WS-ERROR-DESC,
    :HV-RAW-RECORD,
    :WS-FILE-STATUS,
    :WS-TECH-CONTEXT
);


-- -------------------------------------------------
-- 3.7 Cierre de corrida al finalizar el procesamiento
-- -------------------------------------------------
UPDATE FR_BATCH_RUN
   SET END_TS              = CURRENT TIMESTAMP,
       BATCH_STATUS        = :WS-BATCH-STATUS,
       INPUT_COUNT         = :WS-INPUT-COUNT,
       SUCCESS_COUNT       = :WS-SUCCESS-COUNT,
       FUNC_ERROR_COUNT    = :WS-FUNC-ERROR-COUNT,
       TECH_ERROR_COUNT    = :WS-TECH-ERROR-COUNT,
       TOTAL_CREDIT_AMOUNT = :WS-TOTAL-CREDIT,
       TOTAL_DEBIT_AMOUNT  = :WS-TOTAL-DEBIT,
       RETURN_CODE         = :WS-RETURN-CODE
 WHERE RUN_ID = :WS-RUN-ID;


-- ================================================================
-- 4. CONSULTAS DE NEGOCIO, CONTROL Y AUDITORÍA
-- ================================================================

-- ---------------------------------------------------
-- 4.1 Consultar una cuenta y su estado actual
-- ---------------------------------------------------
SELECT ACCOUNT_ID,
       CUSTOMER_ID,
       STATUS,
       CURRENT_BALANCE,
       CREDIT_LIMIT,
       CURRENCY,
       LAST_MOV_DATE,
       LAST_UPD_TS,
       LAST_UPD_RUN_ID
  FROM FR_ACCOUNT_MASTER
 WHERE ACCOUNT_ID = 'ACC0000123';


-- ---------------------------------------------------------
-- 4.2 Resumen de una corrida concreta para operación batch
-- ---------------------------------------------------------
SELECT RUN_ID,
       PROCESS_DATE,
       START_TS,
       END_TS,
       BATCH_STATUS,
       INPUT_COUNT,
       SUCCESS_COUNT,
       FUNC_ERROR_COUNT,
       TECH_ERROR_COUNT,
       TOTAL_CREDIT_AMOUNT,
       TOTAL_DEBIT_AMOUNT,
       RETURN_CODE
  FROM FR_BATCH_RUN
 WHERE RUN_ID = '20260420000001';


-- ---------------------------------------------------------------
-- 4.3 Errores por código en una corrida (soporte y post-mortem)
-- ---------------------------------------------------------------
SELECT ERROR_CODE,
       ERROR_FAMILY,
       COUNT(*) AS NUM_ERRORES
  FROM FR_ERROR_LOG
 WHERE RUN_ID = '20260420000001'
 GROUP BY ERROR_CODE, ERROR_FAMILY
 ORDER BY ERROR_CODE;


-- -----------------------------------------------------------------
-- 4.4 Últimos rechazos de una cuenta para trazabilidad operativa
-- -----------------------------------------------------------------
SELECT RUN_ID,
       TRX_ID,
       ERROR_CODE,
       ERROR_DESC,
       CREATED_TS
  FROM FR_ERROR_LOG
 WHERE ACCOUNT_ID = 'ACC0000123'
 ORDER BY CREATED_TS DESC
 FETCH FIRST 20 ROWS ONLY;


-- --------------------------------------------------------------------
-- 4.5 Histórico de movimientos aceptados de una cuenta entre dos fechas
-- --------------------------------------------------------------------
SELECT RUN_ID,
       TRX_ID,
       OP_TYPE,
       APPLIED_AMOUNT,
       PREV_BALANCE,
       NEW_BALANCE,
       OP_DATE,
       SOURCE_SYSTEM
  FROM FR_RECON_RESULT
 WHERE ACCOUNT_ID = 'ACC0000123'
   AND OP_DATE BETWEEN DATE('2026-04-01') AND DATE('2026-04-30')
 ORDER BY OP_DATE, TRX_ID;


-- ------------------------------------------------------------------
-- 4.6 Corridas con más error funcional para análisis de calidad origen
-- ------------------------------------------------------------------
SELECT PROCESS_DATE,
       RUN_ID,
       FUNC_ERROR_COUNT,
       TECH_ERROR_COUNT,
       SUCCESS_COUNT,
       INPUT_COUNT
  FROM FR_BATCH_RUN
 ORDER BY FUNC_ERROR_COUNT DESC, PROCESS_DATE DESC
 FETCH FIRST 10 ROWS ONLY;


-- -------------------------------------------------------------------
-- 4.7 Reconciliación diaria por sistema origen y tipo de operación
-- -------------------------------------------------------------------
SELECT OP_DATE,
       SOURCE_SYSTEM,
       OP_TYPE,
       COUNT(*)              AS NUM_OPERACIONES,
       SUM(APPLIED_AMOUNT)   AS TOTAL_IMPORTE
  FROM FR_RECON_RESULT
 GROUP BY OP_DATE, SOURCE_SYSTEM, OP_TYPE
 ORDER BY OP_DATE DESC, SOURCE_SYSTEM, OP_TYPE;


-- ---------------------------------------------------------------------
-- 4.8 Detección de cuentas bloqueadas o cerradas con intentos de operación
-- ---------------------------------------------------------------------
SELECT E.ACCOUNT_ID,
       A.STATUS,
       COUNT(*) AS NUM_INTENTOS
  FROM FR_ERROR_LOG E
  JOIN FR_ACCOUNT_MASTER A
    ON A.ACCOUNT_ID = E.ACCOUNT_ID
 WHERE E.ERROR_CODE IN ('E102')
 GROUP BY E.ACCOUNT_ID, A.STATUS
 ORDER BY NUM_INTENTOS DESC;


-- ================================================================
-- 5. MAPEO RECOMENDADO ENTRE REGLAS DEL BATCH Y DB2
-- ================================================================
-- E101 -> Cuenta inexistente
--         Se detecta con SQLCODE = 100 al consultar FR_ACCOUNT_MASTER.
--
-- E102 -> Cuenta no activa (bloqueada o cerrada)
--         STATUS <> 'A'.
--
-- E103 -> Tipo de operación no admitido
--         Se mantiene como validación COBOL previa a SQL.
--
-- E104 -> Importe inválido
--         Se mantiene como validación COBOL previa a SQL.
--
-- E105 -> Divisa incompatible
--         CURRENCY de transacción <> CURRENCY de FR_ACCOUNT_MASTER.
--
-- E106 -> Disponible insuficiente
--         CURRENT_BALANCE + CREDIT_LIMIT < importe del débito.
--
-- E901 -> Error técnico de acceso DB2 / SELECT fallido no esperado.
-- E902 -> Error técnico de actualización DB2 / UPDATE o INSERT fallido.
-- E903 -> Error de integridad / duplicidad / constraint.
-- E904 -> Error de cierre o auditoría inconsistente de la corrida.


-- ================================================================
-- 6. RECOMENDACIONES DE IMPLANTACIÓN FUTURA
-- ================================================================
-- 1) No eliminar todavía ACCOUNTS.DAT en la primera iteración.
--    Mantenerlo como fallback o dataset de contraste mientras se valida
--    la consulta DB2 en entornos de prueba.
--
-- 2) Introducir acceso DB2 solo en los puntos donde hoy se consulta el
--    maestro de cuentas; el resto del batch puede permanecer file-based.
--
-- 3) Mantener RESULTS.DAT y ERRORS.DAT durante una fase transitoria,
--    aunque FR_RECON_RESULT y FR_ERROR_LOG ya guarden la misma evidencia.
--
-- 4) Definir estrategia de COMMIT/ROLLBACK por bloque (por ejemplo cada
--    N transacciones) para equilibrar consistencia y rendimiento.
--
-- 5) Añadir SQLCODE y SQLSTATE al reporte técnico del batch para mejorar
--    soporte operativo y diagnóstico de incidencias DB2.
--
-- 6) En una fase posterior, mover CONTROL.DAT a FR_CTRL_PARAM y dejar la
--    fecha de proceso, strict mode y políticas de descubierto parametrizadas.
--
-- 7) Si el volumen crece, valorar partición lógica por PROCESS_DATE o
--    índices adicionales sobre RUN_ID, ACCOUNT_ID y OP_DATE.
--
-- Resultado esperado de esta extensión:
--   Un proyecto COBOL batch más creíble en entorno enterprise, donde DB2
--   sustituye al maestro de cuentas en fichero y añade trazabilidad real,
--   sin necesidad de reescribir aún todo el proceso de conciliación.
-- ================================================================
