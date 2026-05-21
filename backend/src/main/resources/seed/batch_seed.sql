CREATE TABLE BATCH_JOB_INSTANCE (
    JOB_INSTANCE_ID BIGINT  NOT NULL PRIMARY KEY,
    VERSION BIGINT,
    JOB_NAME VARCHAR(100) NOT NULL,
    JOB_KEY VARCHAR(32) NOT NULL,
    constraint JOB_INST_UN unique (JOB_NAME, JOB_KEY)
);

CREATE TABLE BATCH_JOB_EXECUTION (
    JOB_EXECUTION_ID BIGINT  NOT NULL PRIMARY KEY,
    VERSION BIGINT,
    JOB_INSTANCE_ID BIGINT NOT NULL,
    CREATE_TIME TIMESTAMP NOT NULL,
    START_TIME TIMESTAMP DEFAULT NULL,
    END_TIME TIMESTAMP DEFAULT NULL,
    STATUS VARCHAR(10),
    EXIT_CODE VARCHAR(2500),
    EXIT_MESSAGE VARCHAR(2500),
    LAST_UPDATED TIMESTAMP,
    constraint JOB_INST_EXEC_FK foreign key (JOB_INSTANCE_ID) references BATCH_JOB_INSTANCE(JOB_INSTANCE_ID)
);

CREATE TABLE BATCH_JOB_EXECUTION_PARAMS (
    JOB_EXECUTION_ID BIGINT NOT NULL,
    PARAMETER_NAME VARCHAR(100) NOT NULL,
    PARAMETER_TYPE VARCHAR(100) NOT NULL,
    PARAMETER_VALUE VARCHAR(2500),
    IDENTIFYING CHAR(1) NOT NULL,
    constraint JOB_EXEC_PARAMS_FK foreign key (JOB_EXECUTION_ID) references BATCH_JOB_EXECUTION(JOB_EXECUTION_ID)
) ;

CREATE TABLE BATCH_STEP_EXECUTION (
    STEP_EXECUTION_ID BIGINT  NOT NULL PRIMARY KEY,
    VERSION BIGINT NOT NULL,
    STEP_NAME VARCHAR(100) NOT NULL,
    JOB_EXECUTION_ID BIGINT NOT NULL,
    CREATE_TIME TIMESTAMP NOT NULL,
    START_TIME TIMESTAMP DEFAULT NULL,
    END_TIME TIMESTAMP DEFAULT NULL,
    STATUS VARCHAR(10),
    COMMIT_COUNT BIGINT,
    READ_COUNT BIGINT,
    FILTER_COUNT BIGINT,
    WRITE_COUNT BIGINT,
    READ_SKIP_COUNT BIGINT,
    WRITE_SKIP_COUNT BIGINT,
    PROCESS_SKIP_COUNT BIGINT,
    ROLLBACK_COUNT BIGINT,
    EXIT_CODE VARCHAR(2500),
    EXIT_MESSAGE VARCHAR(2500),
    LAST_UPDATED TIMESTAMP,
    constraint JOB_EXEC_STEP_FK foreign key (JOB_EXECUTION_ID) references BATCH_JOB_EXECUTION(JOB_EXECUTION_ID)
) ;

CREATE TABLE BATCH_STEP_EXECUTION_CONTEXT (
    STEP_EXECUTION_ID BIGINT NOT NULL PRIMARY KEY,
    SHORT_CONTEXT VARCHAR(2500) NOT NULL,
    SERIALIZED_CONTEXT TEXT,
    constraint STEP_EXEC_CTX_FK foreign key (STEP_EXECUTION_ID) references BATCH_STEP_EXECUTION(STEP_EXECUTION_ID)
) ;

CREATE TABLE BATCH_JOB_EXECUTION_CONTEXT (
    JOB_EXECUTION_ID BIGINT NOT NULL PRIMARY KEY,
    SHORT_CONTEXT VARCHAR(2500) NOT NULL,
    SERIALIZED_CONTEXT TEXT,
    constraint JOB_EXEC_CTX_FK foreign key (JOB_EXECUTION_ID) references BATCH_JOB_EXECUTION(JOB_EXECUTION_ID)
) ;

CREATE SEQUENCE BATCH_STEP_EXECUTION_SEQ MAXVALUE 9223372036854775807 NO CYCLE;
CREATE SEQUENCE BATCH_JOB_EXECUTION_SEQ MAXVALUE 9223372036854775807 NO CYCLE;
CREATE SEQUENCE BATCH_JOB_INSTANCE_SEQ MAXVALUE 9223372036854775807 NO CYCLE;

-- =============================================================
--  Spring Batch - Données de test pour dashboard
--  Compatible PostgreSQL / MySQL / H2
--  Couvre : instances, exécutions, steps, paramètres, contextes
-- =============================================================

-- ----------------------------------------------------------------
-- Nettoyage (ordre respectant les FK)
-- ----------------------------------------------------------------
DELETE FROM BATCH_STEP_EXECUTION_CONTEXT;
DELETE FROM BATCH_JOB_EXECUTION_CONTEXT;
DELETE FROM BATCH_STEP_EXECUTION;
DELETE FROM BATCH_JOB_EXECUTION_PARAMS;
DELETE FROM BATCH_JOB_EXECUTION;
DELETE FROM BATCH_JOB_INSTANCE;

-- ----------------------------------------------------------------
-- Séquences (PostgreSQL)
-- ----------------------------------------------------------------
-- ALTER SEQUENCE BATCH_JOB_SEQ              RESTART WITH 100;
-- ALTER SEQUENCE BATCH_JOB_EXECUTION_SEQ    RESTART WITH 200;
-- ALTER SEQUENCE BATCH_STEP_EXECUTION_SEQ   RESTART WITH 500;

-- =============================================================
--  1. BATCH_JOB_INSTANCE
--     Chaque ligne = un job unique identifié par son nom + sa clé
-- =============================================================
INSERT INTO BATCH_JOB_INSTANCE (JOB_INSTANCE_ID, VERSION, JOB_NAME, JOB_KEY) VALUES
--  importCustomerJob  (6 instances → scheduled daily)
(1,  0, 'importCustomerJob',    'a1b2c3d401'),
(2,  0, 'importCustomerJob',    'a1b2c3d402'),
(3,  0, 'importCustomerJob',    'a1b2c3d403'),
(4,  0, 'importCustomerJob',    'a1b2c3d404'),
(5,  0, 'importCustomerJob',    'a1b2c3d405'),
(6,  0, 'importCustomerJob',    'a1b2c3d406'),

--  generateInvoiceJob (5 instances → end-of-month)
(7,  0, 'generateInvoiceJob',   'b2c3d4e501'),
(8,  0, 'generateInvoiceJob',   'b2c3d4e502'),
(9,  0, 'generateInvoiceJob',   'b2c3d4e503'),
(10, 0, 'generateInvoiceJob',   'b2c3d4e504'),
(11, 0, 'generateInvoiceJob',   'b2c3d4e505'),

--  exportReportJob  (4 instances)
(12, 0, 'exportReportJob',      'c3d4e5f601'),
(13, 0, 'exportReportJob',      'c3d4e5f602'),
(14, 0, 'exportReportJob',      'c3d4e5f603'),
(15, 0, 'exportReportJob',      'c3d4e5f604'),

--  cleanupArchiveJob (3 instances → weekly)
(16, 0, 'cleanupArchiveJob',    'd4e5f6a701'),
(17, 0, 'cleanupArchiveJob',    'd4e5f6a702'),
(18, 0, 'cleanupArchiveJob',    'd4e5f6a703'),

--  syncProductCatalogJob (4 instances → e-commerce sync)
(19, 0, 'syncProductCatalogJob','e5f6a7b801'),
(20, 0, 'syncProductCatalogJob','e5f6a7b802'),
(21, 0, 'syncProductCatalogJob','e5f6a7b803'),
(22, 0, 'syncProductCatalogJob','e5f6a7b804'),

--  sendNotificationJob (3 instances)
(23, 0, 'sendNotificationJob',  'f6a7b8c901'),
(24, 0, 'sendNotificationJob',  'f6a7b8c902'),
(25, 0, 'sendNotificationJob',  'f6a7b8c903'),

--  recalculatePricingJob (2 instances → triggered manuellement)
(26, 0, 'recalculatePricingJob','a7b8c9d001'),
(27, 0, 'recalculatePricingJob','a7b8c9d002');


-- =============================================================
--  2. BATCH_JOB_EXECUTION
--     Plusieurs exécutions par instance (retry, reschedule…)
--     EXIT_CODE : COMPLETED | FAILED | NOOP | STOPPED | UNKNOWN
--     STATUS    : COMPLETED | STARTING | STARTED | STOPPING |
--                 STOPPED | FAILED | ABANDONED | UNKNOWN
-- =============================================================
INSERT INTO BATCH_JOB_EXECUTION
(JOB_EXECUTION_ID, VERSION, JOB_INSTANCE_ID,
 CREATE_TIME, START_TIME, END_TIME,
 STATUS, EXIT_CODE, EXIT_MESSAGE,
 LAST_UPDATED)
VALUES

-- ── importCustomerJob ──────────────────────────────────────────
(101, 2, 1,
 '2025-04-01 06:00:00','2025-04-01 06:00:05','2025-04-01 06:12:30',
 'COMPLETED','COMPLETED','', '2025-04-01 06:12:30'),

(102, 2, 2,
 '2025-04-02 06:00:00','2025-04-02 06:00:04','2025-04-02 06:14:10',
 'COMPLETED','COMPLETED','', '2025-04-02 06:14:10'),

(103, 2, 3,
 '2025-04-03 06:00:00','2025-04-03 06:00:06',NULL,
 'FAILED','FAILED',
 'org.springframework.batch.item.ItemReaderException: Connection timeout after 30000ms reading file customers_20250403.csv',
 '2025-04-03 06:03:45'),

-- retry de l'instance 3
(104, 2, 3,
 '2025-04-03 07:30:00','2025-04-03 07:30:10','2025-04-03 07:43:55',
 'COMPLETED','COMPLETED','', '2025-04-03 07:43:55'),

(105, 2, 4,
 '2025-04-04 06:00:00','2025-04-04 06:00:05','2025-04-04 06:15:20',
 'COMPLETED','COMPLETED','', '2025-04-04 06:15:20'),

(106, 2, 5,
 '2025-04-05 06:00:00','2025-04-05 06:00:08',NULL,
 'STARTED','UNKNOWN','', '2025-04-05 06:10:00'),

(107, 2, 6,
 '2025-04-06 06:00:00','2025-04-06 06:00:04','2025-04-06 06:11:45',
 'COMPLETED','COMPLETED','', '2025-04-06 06:11:45'),

-- ── generateInvoiceJob ─────────────────────────────────────────
(108, 2, 7,
 '2025-01-31 22:00:00','2025-01-31 22:00:10','2025-01-31 22:48:33',
 'COMPLETED','COMPLETED','', '2025-01-31 22:48:33'),

(109, 2, 8,
 '2025-02-28 22:00:00','2025-02-28 22:00:08','2025-02-28 23:01:14',
 'COMPLETED','COMPLETED','', '2025-02-28 23:01:14'),

(110, 2, 9,
 '2025-03-31 22:00:00','2025-03-31 22:00:12',NULL,
 'FAILED','FAILED',
 'java.sql.SQLIntegrityConstraintViolationException: Duplicate key invoice_id=INV-99214',
 '2025-03-31 22:15:07'),

(111, 2, 9,
 '2025-04-01 00:00:00','2025-04-01 00:00:20','2025-04-01 00:53:40',
 'COMPLETED','COMPLETED','', '2025-04-01 00:53:40'),

(112, 2, 10,
 '2025-04-30 22:00:00','2025-04-30 22:00:05','2025-04-30 22:51:30',
 'COMPLETED','COMPLETED','', '2025-04-30 22:51:30'),

(113, 1, 11,
 '2025-05-31 22:00:00','2025-05-31 22:00:09',NULL,
 'STARTED','UNKNOWN','', '2025-05-31 22:30:00'),

-- ── exportReportJob ────────────────────────────────────────────
(114, 2, 12,
 '2025-03-10 08:00:00','2025-03-10 08:00:03','2025-03-10 08:07:18',
 'COMPLETED','COMPLETED','', '2025-03-10 08:07:18'),

(115, 2, 13,
 '2025-03-17 08:00:00','2025-03-17 08:00:05','2025-03-17 08:06:55',
 'COMPLETED','COMPLETED','', '2025-03-17 08:06:55'),

(116, 2, 14,
 '2025-03-24 08:00:00','2025-03-24 08:00:04',NULL,
 'STOPPED','STOPPED',
 'Job stopped by operator via JobOperator.stop()',
 '2025-03-24 08:02:11'),

(117, 2, 15,
 '2025-03-31 08:00:00','2025-03-31 08:00:06','2025-03-31 08:08:02',
 'COMPLETED','COMPLETED','', '2025-03-31 08:08:02'),

-- ── cleanupArchiveJob ──────────────────────────────────────────
(118, 2, 16,
 '2025-04-07 01:00:00','2025-04-07 01:00:02','2025-04-07 01:22:14',
 'COMPLETED','COMPLETED','', '2025-04-07 01:22:14'),

(119, 2, 17,
 '2025-04-14 01:00:00','2025-04-14 01:00:03','2025-04-14 01:19:48',
 'COMPLETED','COMPLETED','', '2025-04-14 01:19:48'),

(120, 2, 18,
 '2025-04-21 01:00:00','2025-04-21 01:00:02','2025-04-21 01:18:33',
 'COMPLETED','COMPLETED','', '2025-04-21 01:18:33'),

-- ── syncProductCatalogJob ──────────────────────────────────────
(121, 2, 19,
 '2025-04-01 03:00:00','2025-04-01 03:00:10','2025-04-01 03:35:22',
 'COMPLETED','COMPLETED','', '2025-04-01 03:35:22'),

(122, 2, 20,
 '2025-04-08 03:00:00','2025-04-08 03:00:12',NULL,
 'FAILED','FAILED',
 'com.fasterxml.jackson.core.JsonParseException: Unexpected character at position 1024 in catalog_delta_20250408.json',
 '2025-04-08 03:04:50'),

(123, 2, 21,
 '2025-04-15 03:00:00','2025-04-15 03:00:08','2025-04-15 03:31:09',
 'COMPLETED','COMPLETED','', '2025-04-15 03:31:09'),

(124, 2, 22,
 '2025-04-22 03:00:00','2025-04-22 03:00:11','2025-04-22 03:33:47',
 'COMPLETED','COMPLETED','', '2025-04-22 03:33:47'),

-- ── sendNotificationJob ────────────────────────────────────────
(125, 2, 23,
 '2025-04-01 09:00:00','2025-04-01 09:00:05','2025-04-01 09:03:14',
 'COMPLETED','COMPLETED','', '2025-04-01 09:03:14'),

(126, 2, 24,
 '2025-04-08 09:00:00','2025-04-08 09:00:04','2025-04-08 09:04:02',
 'COMPLETED','COMPLETED','', '2025-04-08 09:04:02'),

(127, 2, 25,
 '2025-04-15 09:00:00','2025-04-15 09:00:06',NULL,
 'ABANDONED','ABANDONED',
 'Job abandoned after 3 consecutive failures – manual intervention required',
 '2025-04-15 09:05:30'),

-- ── recalculatePricingJob ──────────────────────────────────────
(128, 2, 26,
 '2025-03-15 14:00:00','2025-03-15 14:00:15','2025-03-15 14:28:42',
 'COMPLETED','COMPLETED','', '2025-03-15 14:28:42'),

(129, 2, 27,
 '2025-04-10 11:00:00','2025-04-10 11:00:11','2025-04-10 11:31:05',
 'COMPLETED','COMPLETED','', '2025-04-10 11:31:05');


-- =============================================================
--  3. BATCH_JOB_EXECUTION_PARAMS
-- =============================================================
INSERT INTO BATCH_JOB_EXECUTION_PARAMS
(JOB_EXECUTION_ID, PARAMETER_TYPE, PARAMETER_NAME, PARAMETER_VALUE, IDENTIFYING)
VALUES
-- importCustomerJob params
(101,'STRING','inputFile','s3://bucket/customers_20250401.csv','Y'),
(101,'STRING','delimiter',';','N'),
(101,'LONG',  'chunkSize',500,'N'),

(102,'STRING','inputFile','s3://bucket/customers_20250402.csv','Y'),
(102,'LONG',  'chunkSize',500,'N'),

(103,'STRING','inputFile','s3://bucket/customers_20250403.csv','Y'),
(103,'LONG',  'chunkSize',500,'N'),

(104,'STRING','inputFile','s3://bucket/customers_20250403.csv','Y'),
(104,'LONG',  'chunkSize',500,'N'),

(105,'STRING','inputFile','s3://bucket/customers_20250404.csv','Y'),
(105,'LONG',  'chunkSize',500,'N'),

(106,'STRING','inputFile','s3://bucket/customers_20250405.csv','Y'),
(106,'LONG',  'chunkSize',500,'N'),

(107,'STRING','inputFile','s3://bucket/customers_20250406.csv','Y'),
(107,'LONG',  'chunkSize',500,'N'),

-- generateInvoiceJob params
(108,'DATE',  'billingPeriod','2025-01-31 00:00:00','Y'),
(108,'STRING','outputDir','/invoices/2025-01','N'),

(109,'DATE',  'billingPeriod','2025-02-28 00:00:00','Y'),
(109,'STRING','outputDir','/invoices/2025-02','N'),

(110,'DATE',  'billingPeriod','2025-03-31 00:00:00','Y'),
(110,'STRING','outputDir','/invoices/2025-03','N'),

(111,'DATE',  'billingPeriod','2025-03-31 00:00:00','Y'),
(111,'STRING','outputDir','/invoices/2025-03','N'),

(112,'DATE',  'billingPeriod','2025-04-30 00:00:00','Y'),
(112,'STRING','outputDir','/invoices/2025-04','N'),

-- exportReportJob params
(114,'STRING','reportType','MONTHLY_SALES','Y'),
(114,'DATE',  'reportDate','2025-03-10 00:00:00','Y'),

(115,'STRING','reportType','MONTHLY_SALES','Y'),
(115,'DATE',  'reportDate','2025-03-17 00:00:00','Y'),

(116,'STRING','reportType','MONTHLY_SALES','Y'),
(116,'DATE',  'reportDate','2025-03-24 00:00:00','Y'),

(117,'STRING','reportType','MONTHLY_SALES','Y'),
(117,'DATE',  'reportDate','2025-03-31 00:00:00','Y'),

-- cleanupArchiveJob params
(118,'LONG',  'retentionDays',90,'N'),
(119,'LONG',  'retentionDays',90,'N'),
(120,'LONG',  'retentionDays',90,'N'),

-- syncProductCatalogJob params
(121,'STRING','catalogSource','ERP_SYSTEM','Y'),
(121,'STRING','deltaFile','/sync/catalog_delta_20250401.json','N'),

(122,'STRING','catalogSource','ERP_SYSTEM','Y'),
(122,'STRING','deltaFile','/sync/catalog_delta_20250408.json','N'),

(123,'STRING','catalogSource','ERP_SYSTEM','Y'),
(123,'STRING','deltaFile','/sync/catalog_delta_20250415.json','N'),

(124,'STRING','catalogSource','ERP_SYSTEM','Y'),
(124,'STRING','deltaFile','/sync/catalog_delta_20250422.json','N'),

-- sendNotificationJob params
(125,'STRING','channel','EMAIL','N'),
(125,'LONG',  'batchSize',200,'N'),

(126,'STRING','channel','EMAIL','N'),
(126,'LONG',  'batchSize',200,'N'),

(127,'STRING','channel','PUSH','N'),
(127,'LONG',  'batchSize',200,'N'),

-- recalculatePricingJob params
(128,'STRING','pricingStrategy','MARGIN_BASED','Y'),
(128,'DOUBLE','marginRate',0.12,'N'),

(129,'STRING','pricingStrategy','COMPETITOR_BASED','Y'),
(129,'DOUBLE','marginRate',0.08,'N');


-- =============================================================
--  4. BATCH_JOB_EXECUTION_CONTEXT
-- =============================================================
INSERT INTO BATCH_JOB_EXECUTION_CONTEXT (JOB_EXECUTION_ID, SHORT_CONTEXT, SERIALIZED_CONTEXT)
VALUES
    (101,'{"totalLines":18420,"processedLines":18420}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","totalLines":18420,"processedLines":18420,"startedAt":"2025-04-01T06:00:05"}'),
    (102,'{"totalLines":20105,"processedLines":20105}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","totalLines":20105,"processedLines":20105}'),
    (103,'{"totalLines":0,"processedLines":0,"errorAt":"readStep"}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","totalLines":0,"processedLines":0}'),
    (104,'{"totalLines":19883,"processedLines":19883}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","totalLines":19883,"processedLines":19883}'),
    (105,'{"totalLines":21040,"processedLines":21040}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","totalLines":21040,"processedLines":21040}'),
    (106,'{"totalLines":22500,"processedLines":14200}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","totalLines":22500,"processedLines":14200}'),
    (107,'{"totalLines":17800,"processedLines":17800}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","totalLines":17800,"processedLines":17800}'),
    (108,'{"invoicesGenerated":4821,"invoicesSkipped":3,"totalAmount":1284903.42}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","invoicesGenerated":4821,"totalAmount":1284903.42}'),
    (109,'{"invoicesGenerated":4975,"invoicesSkipped":1,"totalAmount":1341250.88}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","invoicesGenerated":4975,"totalAmount":1341250.88}'),
    (110,'{"invoicesGenerated":1200,"invoicesSkipped":0,"errorAt":"writeStep"}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","invoicesGenerated":1200}'),
    (111,'{"invoicesGenerated":5103,"invoicesSkipped":5,"totalAmount":1398721.00}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","invoicesGenerated":5103,"totalAmount":1398721.00}'),
    (112,'{"invoicesGenerated":5250,"invoicesSkipped":2,"totalAmount":1412080.50}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","invoicesGenerated":5250,"totalAmount":1412080.50}'),
    (113,'{"invoicesGenerated":2100,"invoicesSkipped":0}',
     '{"@class":"org.springframework.batch.core.scope.context.JobContext","invoicesGenerated":2100}'),
    (114,'{"rowsExported":8310}','{"@class":"...","rowsExported":8310}'),
    (115,'{"rowsExported":8540}','{"@class":"...","rowsExported":8540}'),
    (116,'{"rowsExported":1230,"stoppedAt":"exportStep"}','{"@class":"...","rowsExported":1230}'),
    (117,'{"rowsExported":8700}','{"@class":"...","rowsExported":8700}'),
    (118,'{"filesDeleted":4521,"bytesFreed":10240000}','{"@class":"...","filesDeleted":4521}'),
    (119,'{"filesDeleted":3840,"bytesFreed":8760000}','{"@class":"...","filesDeleted":3840}'),
    (120,'{"filesDeleted":3120,"bytesFreed":7100000}','{"@class":"...","filesDeleted":3120}'),
    (121,'{"productsUpdated":1420,"productsInserted":80,"productsDeleted":12}','{"@class":"...","productsUpdated":1420}'),
    (122,'{"productsUpdated":0,"parseError":true}','{"@class":"...","parseError":true}'),
    (123,'{"productsUpdated":1310,"productsInserted":45,"productsDeleted":5}','{"@class":"...","productsUpdated":1310}'),
    (124,'{"productsUpdated":1500,"productsInserted":102,"productsDeleted":30}','{"@class":"...","productsUpdated":1500}'),
    (125,'{"notificationsSent":3820,"notificationsFailed":18}','{"@class":"...","notificationsSent":3820}'),
    (126,'{"notificationsSent":4050,"notificationsFailed":9}','{"@class":"...","notificationsSent":4050}'),
    (127,'{"notificationsSent":0,"abandonedReason":"SMTP_DOWN"}','{"@class":"...","abandonedReason":"SMTP_DOWN"}'),
    (128,'{"productsRepriced":12450,"skipped":55}','{"@class":"...","productsRepriced":12450}'),
    (129,'{"productsRepriced":13200,"skipped":32}','{"@class":"...","productsRepriced":13200}');


-- =============================================================
--  5. BATCH_STEP_EXECUTION
--     READ_COUNT, WRITE_COUNT, COMMIT_COUNT, ROLLBACK_COUNT,
--     READ_SKIP_COUNT, PROCESS_SKIP_COUNT, WRITE_SKIP_COUNT
--     FILTER_COUNT
-- =============================================================
INSERT INTO BATCH_STEP_EXECUTION
(STEP_EXECUTION_ID, VERSION, STEP_NAME, JOB_EXECUTION_ID,
 CREATE_TIME, START_TIME, END_TIME,
 STATUS, COMMIT_COUNT, READ_COUNT, FILTER_COUNT,
 WRITE_COUNT, READ_SKIP_COUNT, WRITE_SKIP_COUNT,
 PROCESS_SKIP_COUNT, ROLLBACK_COUNT,
 EXIT_CODE, EXIT_MESSAGE, LAST_UPDATED)
VALUES

-- ── importCustomerJob exec 101 ─────────────────────────────────
(501, 2, 'validateFileStep',     101, '2025-04-01 06:00:04','2025-04-01 06:00:05','2025-04-01 06:00:08',
 'COMPLETED',1,0,0,0,0,0,0,0,'COMPLETED','','2025-04-01 06:00:08'),
(502, 2, 'readAndImportStep',    101, '2025-04-01 06:00:07','2025-04-01 06:00:08','2025-04-01 06:12:10',
 'COMPLETED',37,18500,80,18420,12,0,0,0,'COMPLETED','','2025-04-01 06:12:10'),
(503, 2, 'indexUpdateStep',      101, '2025-04-01 06:12:09','2025-04-01 06:12:10','2025-04-01 06:12:30',
 'COMPLETED',1,18420,0,18420,0,0,0,0,'COMPLETED','','2025-04-01 06:12:30'),

-- ── importCustomerJob exec 102 ─────────────────────────────────
(504, 2, 'validateFileStep',     102, '2025-04-02 06:00:03','2025-04-02 06:00:04','2025-04-02 06:00:07',
 'COMPLETED',1,0,0,0,0,0,0,0,'COMPLETED','','2025-04-02 06:00:07'),
(505, 2, 'readAndImportStep',    102, '2025-04-02 06:00:06','2025-04-02 06:00:07','2025-04-02 06:13:45',
 'COMPLETED',41,20200,95,20105,21,0,0,0,'COMPLETED','','2025-04-02 06:13:45'),
(506, 2, 'indexUpdateStep',      102, '2025-04-02 06:13:44','2025-04-02 06:13:45','2025-04-02 06:14:10',
 'COMPLETED',1,20105,0,20105,0,0,0,0,'COMPLETED','','2025-04-02 06:14:10'),

-- ── importCustomerJob exec 103 (FAILED) ────────────────────────
(507, 1, 'validateFileStep',     103, '2025-04-03 06:00:05','2025-04-03 06:00:06','2025-04-03 06:03:45',
 'FAILED',0,0,0,0,0,0,0,0,'FAILED',
 'Connection timeout after 30000ms','2025-04-03 06:03:45'),

-- ── importCustomerJob exec 104 (retry OK) ─────────────────────
(508, 2, 'validateFileStep',     104, '2025-04-03 07:30:09','2025-04-03 07:30:10','2025-04-03 07:30:13',
 'COMPLETED',1,0,0,0,0,0,0,0,'COMPLETED','','2025-04-03 07:30:13'),
(509, 2, 'readAndImportStep',    104, '2025-04-03 07:30:12','2025-04-03 07:30:13','2025-04-03 07:43:22',
 'COMPLETED',40,20000,117,19883,33,0,0,0,'COMPLETED','','2025-04-03 07:43:22'),
(510, 2, 'indexUpdateStep',      104, '2025-04-03 07:43:21','2025-04-03 07:43:22','2025-04-03 07:43:55',
 'COMPLETED',1,19883,0,19883,0,0,0,0,'COMPLETED','','2025-04-03 07:43:55'),

-- ── importCustomerJob exec 105 ─────────────────────────────────
(511, 2, 'validateFileStep',     105, '2025-04-04 06:00:04','2025-04-04 06:00:05','2025-04-04 06:00:08',
 'COMPLETED',1,0,0,0,0,0,0,0,'COMPLETED','','2025-04-04 06:00:08'),
(512, 2, 'readAndImportStep',    105, '2025-04-04 06:00:07','2025-04-04 06:00:08','2025-04-04 06:14:52',
 'COMPLETED',43,21150,110,21040,9,0,0,0,'COMPLETED','','2025-04-04 06:14:52'),
(513, 2, 'indexUpdateStep',      105, '2025-04-04 06:14:51','2025-04-04 06:14:52','2025-04-04 06:15:20',
 'COMPLETED',1,21040,0,21040,0,0,0,0,'COMPLETED','','2025-04-04 06:15:20'),

-- ── importCustomerJob exec 106 (STARTED / en cours) ────────────
(514, 1, 'validateFileStep',     106, '2025-04-05 06:00:07','2025-04-05 06:00:08','2025-04-05 06:00:11',
 'COMPLETED',1,0,0,0,0,0,0,0,'COMPLETED','','2025-04-05 06:00:11'),
(515, 1, 'readAndImportStep',    106, '2025-04-05 06:00:10','2025-04-05 06:00:11',NULL,
 'STARTED',28,14200,60,14080,8,0,0,0,'STARTED','','2025-04-05 06:10:00'),

-- ── importCustomerJob exec 107 ─────────────────────────────────
(516, 2, 'validateFileStep',     107, '2025-04-06 06:00:03','2025-04-06 06:00:04','2025-04-06 06:00:07',
 'COMPLETED',1,0,0,0,0,0,0,0,'COMPLETED','','2025-04-06 06:00:07'),
(517, 2, 'readAndImportStep',    107, '2025-04-06 06:00:06','2025-04-06 06:00:07','2025-04-06 06:11:28',
 'COMPLETED',36,17900,100,17800,2,0,0,0,'COMPLETED','','2025-04-06 06:11:28'),
(518, 2, 'indexUpdateStep',      107, '2025-04-06 06:11:27','2025-04-06 06:11:28','2025-04-06 06:11:45',
 'COMPLETED',1,17800,0,17800,0,0,0,0,'COMPLETED','','2025-04-06 06:11:45'),

-- ── generateInvoiceJob exec 108 ────────────────────────────────
(519, 2, 'fetchCustomersStep',   108, '2025-01-31 22:00:09','2025-01-31 22:00:10','2025-01-31 22:03:22',
 'COMPLETED',10,4824,0,4824,0,0,0,0,'COMPLETED','','2025-01-31 22:03:22'),
(520, 2, 'generatePdfStep',      108, '2025-01-31 22:03:21','2025-01-31 22:03:22','2025-01-31 22:44:18',
 'COMPLETED',49,4824,0,4821,0,3,0,0,'COMPLETED','','2025-01-31 22:44:18'),
(521, 2, 'sendEmailStep',        108, '2025-01-31 22:44:17','2025-01-31 22:44:18','2025-01-31 22:48:33',
 'COMPLETED',10,4821,0,4821,0,0,0,0,'COMPLETED','','2025-01-31 22:48:33'),

-- ── generateInvoiceJob exec 109 ────────────────────────────────
(522, 2, 'fetchCustomersStep',   109, '2025-02-28 22:00:07','2025-02-28 22:00:08','2025-02-28 22:03:55',
 'COMPLETED',10,4976,0,4976,0,0,0,0,'COMPLETED','','2025-02-28 22:03:55'),
(523, 2, 'generatePdfStep',      109, '2025-02-28 22:03:54','2025-02-28 22:03:55','2025-02-28 22:57:30',
 'COMPLETED',50,4976,0,4975,0,1,0,0,'COMPLETED','','2025-02-28 22:57:30'),
(524, 2, 'sendEmailStep',        109, '2025-02-28 22:57:29','2025-02-28 22:57:30','2025-02-28 23:01:14',
 'COMPLETED',10,4975,0,4975,0,0,0,0,'COMPLETED','','2025-02-28 23:01:14'),

-- ── generateInvoiceJob exec 110 (FAILED mid-write) ─────────────
(525, 2, 'fetchCustomersStep',   110, '2025-03-31 22:00:11','2025-03-31 22:00:12','2025-03-31 22:04:00',
 'COMPLETED',10,5108,0,5108,0,0,0,0,'COMPLETED','','2025-03-31 22:04:00'),
(526, 1, 'generatePdfStep',      110, '2025-03-31 22:03:59','2025-03-31 22:04:00','2025-03-31 22:15:07',
 'FAILED',12,1200,0,1200,0,0,0,1,'FAILED',
 'Duplicate key violation on invoice_id=INV-99214','2025-03-31 22:15:07'),

-- ── generateInvoiceJob exec 111 (retry) ────────────────────────
(527, 2, 'fetchCustomersStep',   111, '2025-04-01 00:00:19','2025-04-01 00:00:20','2025-04-01 00:04:10',
 'COMPLETED',11,5108,0,5108,0,0,0,0,'COMPLETED','','2025-04-01 00:04:10'),
(528, 2, 'generatePdfStep',      111, '2025-04-01 00:04:09','2025-04-01 00:04:10','2025-04-01 00:49:55',
 'COMPLETED',51,5108,0,5103,0,5,0,0,'COMPLETED','','2025-04-01 00:49:55'),
(529, 2, 'sendEmailStep',        111, '2025-04-01 00:49:54','2025-04-01 00:49:55','2025-04-01 00:53:40',
 'COMPLETED',11,5103,0,5103,0,0,0,0,'COMPLETED','','2025-04-01 00:53:40'),

-- ── generateInvoiceJob exec 112 ────────────────────────────────
(530, 2, 'fetchCustomersStep',   112, '2025-04-30 22:00:04','2025-04-30 22:00:05','2025-04-30 22:04:30',
 'COMPLETED',11,5252,0,5252,0,0,0,0,'COMPLETED','','2025-04-30 22:04:30'),
(531, 2, 'generatePdfStep',      112, '2025-04-30 22:04:29','2025-04-30 22:04:30','2025-04-30 22:47:40',
 'COMPLETED',53,5252,0,5250,0,2,0,0,'COMPLETED','','2025-04-30 22:47:40'),
(532, 2, 'sendEmailStep',        112, '2025-04-30 22:47:39','2025-04-30 22:47:40','2025-04-30 22:51:30',
 'COMPLETED',11,5250,0,5250,0,0,0,0,'COMPLETED','','2025-04-30 22:51:30'),

-- ── exportReportJob exec 114 ───────────────────────────────────
(533, 2, 'queryDataStep',        114, '2025-03-10 08:00:02','2025-03-10 08:00:03','2025-03-10 08:04:55',
 'COMPLETED',9,8310,0,8310,0,0,0,0,'COMPLETED','','2025-03-10 08:04:55'),
(534, 2, 'exportCsvStep',        114, '2025-03-10 08:04:54','2025-03-10 08:04:55','2025-03-10 08:07:18',
 'COMPLETED',9,8310,0,8310,0,0,0,0,'COMPLETED','','2025-03-10 08:07:18'),

-- ── exportReportJob exec 116 (STOPPED) ────────────────────────
(535, 1, 'queryDataStep',        116, '2025-03-24 08:00:03','2025-03-24 08:00:04','2025-03-24 08:01:30',
 'COMPLETED',3,1230,0,1230,0,0,0,0,'COMPLETED','','2025-03-24 08:01:30'),
(536, 1, 'exportCsvStep',        116, '2025-03-24 08:01:29','2025-03-24 08:01:30','2025-03-24 08:02:11',
 'STOPPED',1,1230,0,800,0,0,0,0,'STOPPED',
 'StepExecution stopped by operator','2025-03-24 08:02:11'),

-- ── cleanupArchiveJob exec 118 ─────────────────────────────────
(537, 2, 'scanArchivesStep',     118, '2025-04-07 01:00:01','2025-04-07 01:00:02','2025-04-07 01:05:14',
 'COMPLETED',1,4521,0,4521,0,0,0,0,'COMPLETED','','2025-04-07 01:05:14'),
(538, 2, 'deleteFilesStep',      118, '2025-04-07 01:05:13','2025-04-07 01:05:14','2025-04-07 01:22:14',
 'COMPLETED',10,4521,0,4521,0,0,0,0,'COMPLETED','','2025-04-07 01:22:14'),

-- ── cleanupArchiveJob exec 119 ─────────────────────────────────
(539, 2, 'scanArchivesStep',     119, '2025-04-14 01:00:02','2025-04-14 01:00:03','2025-04-14 01:04:48',
 'COMPLETED',1,3840,0,3840,0,0,0,0,'COMPLETED','','2025-04-14 01:04:48'),
(540, 2, 'deleteFilesStep',      119, '2025-04-14 01:04:47','2025-04-14 01:04:48','2025-04-14 01:19:48',
 'COMPLETED',8,3840,0,3840,0,0,0,0,'COMPLETED','','2025-04-14 01:19:48'),

-- ── cleanupArchiveJob exec 120 ─────────────────────────────────
(541, 2, 'scanArchivesStep',     120, '2025-04-21 01:00:01','2025-04-21 01:00:02','2025-04-21 01:03:55',
 'COMPLETED',1,3120,0,3120,0,0,0,0,'COMPLETED','','2025-04-21 01:03:55'),
(542, 2, 'deleteFilesStep',      120, '2025-04-21 01:03:54','2025-04-21 01:03:55','2025-04-21 01:18:33',
 'COMPLETED',7,3120,0,3120,0,0,0,0,'COMPLETED','','2025-04-21 01:18:33'),

-- ── syncProductCatalogJob exec 121 ────────────────────────────
(543, 2, 'parseJsonStep',        121, '2025-04-01 03:00:09','2025-04-01 03:00:10','2025-04-01 03:05:30',
 'COMPLETED',1,1512,0,1512,0,0,0,0,'COMPLETED','','2025-04-01 03:05:30'),
(544, 2, 'upsertProductsStep',   121, '2025-04-01 03:05:29','2025-04-01 03:05:30','2025-04-01 03:30:44',
 'COMPLETED',31,1512,0,1500,0,0,0,0,'COMPLETED','','2025-04-01 03:30:44'),
(545, 2, 'rebuildSearchIndexStep',121,'2025-04-01 03:30:43','2025-04-01 03:30:44','2025-04-01 03:35:22',
 'COMPLETED',1,1500,0,1500,0,0,0,0,'COMPLETED','','2025-04-01 03:35:22'),

-- ── syncProductCatalogJob exec 122 (FAILED at parse) ──────────
(546, 1, 'parseJsonStep',        122, '2025-04-08 03:00:11','2025-04-08 03:00:12','2025-04-08 03:04:50',
 'FAILED',0,0,0,0,0,0,0,0,'FAILED',
 'JsonParseException at byte offset 1024','2025-04-08 03:04:50'),

-- ── syncProductCatalogJob exec 123 ────────────────────────────
(547, 2, 'parseJsonStep',        123, '2025-04-15 03:00:07','2025-04-15 03:00:08','2025-04-15 03:05:00',
 'COMPLETED',1,1360,0,1360,0,0,0,0,'COMPLETED','','2025-04-15 03:05:00'),
(548, 2, 'upsertProductsStep',   123, '2025-04-15 03:04:59','2025-04-15 03:05:00','2025-04-15 03:28:30',
 'COMPLETED',28,1360,0,1355,0,0,0,0,'COMPLETED','','2025-04-15 03:28:30'),
(549, 2, 'rebuildSearchIndexStep',123,'2025-04-15 03:28:29','2025-04-15 03:28:30','2025-04-15 03:31:09',
 'COMPLETED',1,1355,0,1355,0,0,0,0,'COMPLETED','','2025-04-15 03:31:09'),

-- ── syncProductCatalogJob exec 124 ────────────────────────────
(550, 2, 'parseJsonStep',        124, '2025-04-22 03:00:10','2025-04-22 03:00:11','2025-04-22 03:06:00',
 'COMPLETED',1,1632,0,1632,0,0,0,0,'COMPLETED','','2025-04-22 03:06:00'),
(551, 2, 'upsertProductsStep',   124, '2025-04-22 03:05:59','2025-04-22 03:06:00','2025-04-22 03:29:40',
 'COMPLETED',33,1632,0,1602,0,0,0,0,'COMPLETED','','2025-04-22 03:29:40'),
(552, 2, 'rebuildSearchIndexStep',124,'2025-04-22 03:29:39','2025-04-22 03:29:40','2025-04-22 03:33:47',
 'COMPLETED',1,1602,0,1602,0,0,0,0,'COMPLETED','','2025-04-22 03:33:47'),

-- ── sendNotificationJob exec 125 ──────────────────────────────
(553, 2, 'loadRecipientsStep',   125, '2025-04-01 09:00:04','2025-04-01 09:00:05','2025-04-01 09:00:40',
 'COMPLETED',1,3838,0,3838,0,0,0,0,'COMPLETED','','2025-04-01 09:00:40'),
(554, 2, 'sendEmailStep',        125, '2025-04-01 09:00:39','2025-04-01 09:00:40','2025-04-01 09:03:14',
 'COMPLETED',20,3838,0,3820,0,18,0,0,'COMPLETED','','2025-04-01 09:03:14'),

-- ── sendNotificationJob exec 126 ──────────────────────────────
(555, 2, 'loadRecipientsStep',   126, '2025-04-08 09:00:03','2025-04-08 09:00:04','2025-04-08 09:00:42',
 'COMPLETED',1,4059,0,4059,0,0,0,0,'COMPLETED','','2025-04-08 09:00:42'),
(556, 2, 'sendEmailStep',        126, '2025-04-08 09:00:41','2025-04-08 09:00:42','2025-04-08 09:04:02',
 'COMPLETED',21,4059,0,4050,0,9,0,0,'COMPLETED','','2025-04-08 09:04:02'),

-- ── sendNotificationJob exec 127 (ABANDONED) ──────────────────
(557, 1, 'loadRecipientsStep',   127, '2025-04-15 09:00:05','2025-04-15 09:00:06','2025-04-15 09:01:30',
 'COMPLETED',1,3900,0,3900,0,0,0,0,'COMPLETED','','2025-04-15 09:01:30'),
(558, 1, 'sendEmailStep',        127, '2025-04-15 09:01:29','2025-04-15 09:01:30','2025-04-15 09:05:30',
 'ABANDONED',0,0,0,0,0,0,0,3,'ABANDONED',
 'SMTP connection refused – host=mail.internal port=587','2025-04-15 09:05:30'),

-- ── recalculatePricingJob exec 128 ────────────────────────────
(559, 2, 'loadPricingRulesStep', 128, '2025-03-15 14:00:14','2025-03-15 14:00:15','2025-03-15 14:01:00',
 'COMPLETED',1,155,0,155,0,0,0,0,'COMPLETED','','2025-03-15 14:01:00'),
(560, 2, 'repricingStep',        128, '2025-03-15 14:00:59','2025-03-15 14:01:00','2025-03-15 14:26:30',
 'COMPLETED',25,12505,0,12450,0,55,0,0,'COMPLETED','','2025-03-15 14:26:30'),
(561, 2, 'publishPriceEventsStep',128,'2025-03-15 14:26:29','2025-03-15 14:26:30','2025-03-15 14:28:42',
 'COMPLETED',25,12450,0,12450,0,0,0,0,'COMPLETED','','2025-03-15 14:28:42'),

-- ── recalculatePricingJob exec 129 ────────────────────────────
(562, 2, 'loadPricingRulesStep', 129, '2025-04-10 11:00:10','2025-04-10 11:00:11','2025-04-10 11:01:00',
 'COMPLETED',1,162,0,162,0,0,0,0,'COMPLETED','','2025-04-10 11:01:00'),
(563, 2, 'repricingStep',        129, '2025-04-10 11:00:59','2025-04-10 11:01:00','2025-04-10 11:28:50',
 'COMPLETED',27,13232,0,13200,0,32,0,0,'COMPLETED','','2025-04-10 11:28:50'),
(564, 2, 'publishPriceEventsStep',129,'2025-04-10 11:28:49','2025-04-10 11:28:50','2025-04-10 11:31:05',
 'COMPLETED',27,13200,0,13200,0,0,0,0,'COMPLETED','','2025-04-10 11:31:05');

-- =============================================================
--  6. BATCH_STEP_EXECUTION_CONTEXT
-- =============================================================
INSERT INTO BATCH_STEP_EXECUTION_CONTEXT (STEP_EXECUTION_ID, SHORT_CONTEXT, SERIALIZED_CONTEXT)
VALUES
    (501,'{"batch.taskletType":"ValidateFileTasklet"}','{"@class":"...","validated":true}'),
    (502,'{"FlatFileItemReader.read.count":18500}','{"@class":"...","readCount":18500,"writeCount":18420}'),
    (503,'{"IndexUpdateTasklet.count":18420}','{"@class":"..."}'),

    (504,'{"batch.taskletType":"ValidateFileTasklet"}','{"@class":"...","validated":true}'),
    (505,'{"FlatFileItemReader.read.count":20200}','{"@class":"...","readCount":20200}'),
    (506,'{"IndexUpdateTasklet.count":20105}','{"@class":"..."}'),

    (507,'{"batch.taskletType":"ValidateFileTasklet","error":"timeout"}','{"@class":"...","error":"timeout"}'),

    (508,'{"batch.taskletType":"ValidateFileTasklet"}','{"@class":"...","validated":true}'),
    (509,'{"FlatFileItemReader.read.count":20000}','{"@class":"...","readCount":20000}'),
    (510,'{"IndexUpdateTasklet.count":19883}','{"@class":"..."}'),

    (511,'{"batch.taskletType":"ValidateFileTasklet"}','{"@class":"...","validated":true}'),
    (512,'{"FlatFileItemReader.read.count":21150}','{"@class":"...","readCount":21150}'),
    (513,'{"IndexUpdateTasklet.count":21040}','{"@class":"..."}'),

    (514,'{"batch.taskletType":"ValidateFileTasklet"}','{"@class":"...","validated":true}'),
    (515,'{"FlatFileItemReader.read.count":14200}','{"@class":"...","readCount":14200,"inProgress":true}'),

    (516,'{"batch.taskletType":"ValidateFileTasklet"}','{"@class":"...","validated":true}'),
    (517,'{"FlatFileItemReader.read.count":17900}','{"@class":"...","readCount":17900}'),
    (518,'{"IndexUpdateTasklet.count":17800}','{"@class":"..."}'),

    (519,'{"JdbcCursorItemReader.read.count":4824}','{"@class":"...","readCount":4824}'),
    (520,'{"PdfGeneratorItemWriter.write.count":4821}','{"@class":"...","writeCount":4821}'),
    (521,'{"SmtpItemWriter.sent.count":4821}','{"@class":"...","sent":4821}'),

    (522,'{"JdbcCursorItemReader.read.count":4976}','{"@class":"..."}'),
    (523,'{"PdfGeneratorItemWriter.write.count":4975}','{"@class":"..."}'),
    (524,'{"SmtpItemWriter.sent.count":4975}','{"@class":"..."}'),

    (525,'{"JdbcCursorItemReader.read.count":5108}','{"@class":"..."}'),
    (526,'{"PdfGeneratorItemWriter.write.count":1200,"error":"DuplicateKey"}','{"@class":"...","error":"DuplicateKey"}'),

    (527,'{"JdbcCursorItemReader.read.count":5108}','{"@class":"..."}'),
    (528,'{"PdfGeneratorItemWriter.write.count":5103}','{"@class":"..."}'),
    (529,'{"SmtpItemWriter.sent.count":5103}','{"@class":"..."}'),

    (530,'{"JdbcCursorItemReader.read.count":5252}','{"@class":"..."}'),
    (531,'{"PdfGeneratorItemWriter.write.count":5250}','{"@class":"..."}'),
    (532,'{"SmtpItemWriter.sent.count":5250}','{"@class":"..."}'),

    (533,'{"JdbcPagingItemReader.read.count":8310}','{"@class":"..."}'),
    (534,'{"FlatFileItemWriter.write.count":8310}','{"@class":"..."}'),

    (535,'{"JdbcPagingItemReader.read.count":1230}','{"@class":"..."}'),
    (536,'{"FlatFileItemWriter.write.count":800,"stopped":true}','{"@class":"...","stopped":true}'),

    (537,'{"ScanArchivesTasklet.found":4521}','{"@class":"..."}'),
    (538,'{"DeleteFilesTasklet.deleted":4521}','{"@class":"..."}'),

    (539,'{"ScanArchivesTasklet.found":3840}','{"@class":"..."}'),
    (540,'{"DeleteFilesTasklet.deleted":3840}','{"@class":"..."}'),

    (541,'{"ScanArchivesTasklet.found":3120}','{"@class":"..."}'),
    (542,'{"DeleteFilesTasklet.deleted":3120}','{"@class":"..."}'),

    (543,'{"JsonItemReader.read.count":1512}','{"@class":"..."}'),
    (544,'{"JdbcBatchItemWriter.write.count":1500}','{"@class":"..."}'),
    (545,'{"RebuildIndexTasklet.indexed":1500}','{"@class":"..."}'),

    (546,'{"JsonItemReader.error":"JsonParseException"}','{"@class":"...","error":"JsonParseException"}'),

    (547,'{"JsonItemReader.read.count":1360}','{"@class":"..."}'),
    (548,'{"JdbcBatchItemWriter.write.count":1355}','{"@class":"..."}'),
    (549,'{"RebuildIndexTasklet.indexed":1355}','{"@class":"..."}'),

    (550,'{"JsonItemReader.read.count":1632}','{"@class":"..."}'),
    (551,'{"JdbcBatchItemWriter.write.count":1602}','{"@class":"..."}'),
    (552,'{"RebuildIndexTasklet.indexed":1602}','{"@class":"..."}'),

    (553,'{"JdbcCursorItemReader.read.count":3838}','{"@class":"..."}'),
    (554,'{"SmtpItemWriter.sent.count":3820,"failed":18}','{"@class":"..."}'),

    (555,'{"JdbcCursorItemReader.read.count":4059}','{"@class":"..."}'),
    (556,'{"SmtpItemWriter.sent.count":4050,"failed":9}','{"@class":"..."}'),

    (557,'{"JdbcCursorItemReader.read.count":3900}','{"@class":"..."}'),
    (558,'{"SmtpItemWriter.error":"ConnectionRefused"}','{"@class":"...","error":"ConnectionRefused"}'),

    (559,'{"JdbcCursorItemReader.read.count":155}','{"@class":"..."}'),
    (560,'{"JdbcBatchItemWriter.write.count":12450,"skipped":55}','{"@class":"..."}'),
    (561,'{"KafkaItemWriter.published.count":12450}','{"@class":"..."}'),

    (562,'{"JdbcCursorItemReader.read.count":162}','{"@class":"..."}'),
    (563,'{"JdbcBatchItemWriter.write.count":13200,"skipped":32}','{"@class":"..."}'),
    (564,'{"KafkaItemWriter.published.count":13200}','{"@class":"..."}');


-- =============================================================
--  REQUÊTES UTILES POUR LE DASHBOARD
-- =============================================================
/*
-- Taux de succès par job
SELECT
    ji.JOB_NAME,
    COUNT(*)                                                      AS total_executions,
    SUM(CASE WHEN je.STATUS = 'COMPLETED' THEN 1 ELSE 0 END)     AS successful,
    SUM(CASE WHEN je.STATUS = 'FAILED'    THEN 1 ELSE 0 END)     AS failed,
    SUM(CASE WHEN je.STATUS = 'STARTED'   THEN 1 ELSE 0 END)     AS running,
    ROUND(100.0 * SUM(CASE WHEN je.STATUS = 'COMPLETED' THEN 1 ELSE 0 END)
          / COUNT(*), 1)                                          AS success_rate_pct
FROM BATCH_JOB_EXECUTION je
JOIN BATCH_JOB_INSTANCE  ji ON ji.JOB_INSTANCE_ID = je.JOB_INSTANCE_ID
GROUP BY ji.JOB_NAME
ORDER BY ji.JOB_NAME;

-- Durée moyenne d'exécution par job (minutes)
SELECT
    ji.JOB_NAME,
    ROUND(AVG(TIMESTAMPDIFF(SECOND, je.START_TIME, je.END_TIME)) / 60.0, 2) AS avg_duration_min,
    MAX(TIMESTAMPDIFF(SECOND, je.START_TIME, je.END_TIME)) / 60.0            AS max_duration_min
FROM BATCH_JOB_EXECUTION je
JOIN BATCH_JOB_INSTANCE  ji ON ji.JOB_INSTANCE_ID = je.JOB_INSTANCE_ID
WHERE je.END_TIME IS NOT NULL
GROUP BY ji.JOB_NAME;

-- Statistiques de lecture/écriture par step
SELECT
    ji.JOB_NAME,
    se.STEP_NAME,
    SUM(se.READ_COUNT)         AS total_read,
    SUM(se.WRITE_COUNT)        AS total_written,
    SUM(se.READ_SKIP_COUNT
      + se.WRITE_SKIP_COUNT
      + se.PROCESS_SKIP_COUNT) AS total_skipped,
    SUM(se.ROLLBACK_COUNT)     AS total_rollbacks
FROM BATCH_STEP_EXECUTION se
JOIN BATCH_JOB_EXECUTION  je ON je.JOB_EXECUTION_ID = se.JOB_EXECUTION_ID
JOIN BATCH_JOB_INSTANCE   ji ON ji.JOB_INSTANCE_ID  = je.JOB_INSTANCE_ID
GROUP BY ji.JOB_NAME, se.STEP_NAME
ORDER BY ji.JOB_NAME, se.STEP_NAME;

-- Dernières exécutions (toutes)
SELECT
    ji.JOB_NAME,
    je.JOB_EXECUTION_ID,
    je.START_TIME,
    je.END_TIME,
    je.STATUS,
    je.EXIT_CODE
FROM BATCH_JOB_EXECUTION je
JOIN BATCH_JOB_INSTANCE  ji ON ji.JOB_INSTANCE_ID = je.JOB_INSTANCE_ID
ORDER BY je.START_TIME DESC
LIMIT 20;
*/
