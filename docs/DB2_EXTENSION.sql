-- Propuesta de evolución a DB2 para HISPALIS-FINRECON
-- Objetivo: sustituir parcialmente el maestro plano por persistencia relacional
-- y añadir trazabilidad de ejecución batch.

CREATE TABLE FIN_ACCOUNT_MASTER (
    ACCOUNT_ID           CHAR(10)      NOT NULL,
    ACCOUNT_NAME         VARCHAR(60)   NOT NULL,
    ACCOUNT_STATUS       CHAR(1)       NOT NULL,
    CURRENCY_CODE        CHAR(3)       NOT NULL,
    CURRENT_BALANCE      DECIMAL(13,2) NOT NULL,
    LAST_UPDATE_DATE     DATE          NOT NULL,
    PRIMARY KEY (ACCOUNT_ID)
);

CREATE TABLE FIN_BATCH_RUN (
    BATCH_RUN_ID         BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY,
    PROCESS_DATE         DATE          NOT NULL,
    PROCESS_TS           TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
    INPUT_TRANS_COUNT    INTEGER       NOT NULL,
    OK_TRANS_COUNT       INTEGER       NOT NULL,
    ERROR_TRANS_COUNT    INTEGER       NOT NULL,
    TOTAL_DEBIT_AMOUNT   DECIMAL(13,2) NOT NULL,
    TOTAL_CREDIT_AMOUNT  DECIMAL(13,2) NOT NULL,
    RETURN_CODE          INTEGER       NOT NULL,
    PRIMARY KEY (BATCH_RUN_ID)
);

CREATE TABLE FIN_TRANSACTION_AUDIT (
    AUDIT_ID             BIGINT        NOT NULL GENERATED ALWAYS AS IDENTITY,
    BATCH_RUN_ID         BIGINT        NOT NULL,
    TRN_ID               CHAR(12)      NOT NULL,
    ACCOUNT_ID           CHAR(10),
    TRN_DATE             DATE          NOT NULL,
    TRN_TYPE             CHAR(1)       NOT NULL,
    TRN_AMOUNT           DECIMAL(13,2) NOT NULL,
    TRN_CURRENCY         CHAR(3)       NOT NULL,
    PROCESS_STATUS       CHAR(1)       NOT NULL,
    ERROR_CODE           CHAR(4),
    ERROR_MESSAGE        VARCHAR(80),
    CREATED_TS           TIMESTAMP     NOT NULL DEFAULT CURRENT TIMESTAMP,
    PRIMARY KEY (AUDIT_ID),
    CONSTRAINT FK_BATCH_RUN
        FOREIGN KEY (BATCH_RUN_ID)
        REFERENCES FIN_BATCH_RUN (BATCH_RUN_ID)
);

CREATE INDEX IX_FIN_AUDIT_TRN_ID
    ON FIN_TRANSACTION_AUDIT (TRN_ID);

CREATE INDEX IX_FIN_AUDIT_ACCOUNT_ID
    ON FIN_TRANSACTION_AUDIT (ACCOUNT_ID);

-- Posibles evoluciones:
-- 1) lectura de maestro desde DB2 y actualización de saldos en COMMIT por lote
-- 2) persistencia de errores funcionales para reporting operativo
-- 3) tabla de catálogo de errores y severidades
-- 4) trazabilidad de restart/checkpoint
