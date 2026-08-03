-- =====================================================================
-- Proyecto:    Sistema de Gestión de Servicios Cloud y Soporte Técnico
-- Empresa:     RoxMonTech
-- Motor:       mySQL
-- Convención:  db_[nombre] / tbl_[entidad] / [entidad]_[atributo]
--              PK: [entidad]_id | Prefijos: pk_, fk_, uk_, idx_
--              Eliminación lógica mediante columna *_est ('A' Activo / 'I' Inactivo)
-- =====================================================================

DROP DATABASE IF EXISTS db_roxmontech;
CREATE DATABASE db_roxmontech CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci;
USE db_roxmontech;

-- ---------------------------------------------------------------------
-- Tabla 1: tbl_usu (Gestión de Usuarios internos)
-- Almacena a los empleados que gestionan clientes, contratos y tickets.
-- ---------------------------------------------------------------------
CREATE TABLE tbl_usu (
    usu_id       INT AUTO_INCREMENT,
    usu_nom      VARCHAR(100)  NOT NULL,
    usu_ape      VARCHAR(100)  NOT NULL,
    usu_cor      VARCHAR(150)  NOT NULL,
    usu_pas      VARCHAR(255)  NOT NULL,
    usu_rol      VARCHAR(30)   NOT NULL DEFAULT 'Tecnico',
    usu_est      CHAR(1)       NOT NULL DEFAULT 'A',
    usu_fec_cre  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_usu_id  PRIMARY KEY (usu_id),
    CONSTRAINT uk_usu_cor UNIQUE (usu_cor),
    CONSTRAINT ck_usu_rol CHECK (usu_rol IN ('Administrador','Tecnico','Ventas')),
    CONSTRAINT ck_usu_est CHECK (usu_est IN ('A','I'))
);

-- ---------------------------------------------------------------------
-- Tabla 2: tbl_cli (Gestión de Clientes)
-- Empresas o personas que contratan servicios de software/cloud.
-- ---------------------------------------------------------------------
CREATE TABLE tbl_cli (
    cli_id       INT AUTO_INCREMENT,
    cli_raz      VARCHAR(150)  NOT NULL,
    cli_ide      VARCHAR(13)   NOT NULL,
    cli_cor      VARCHAR(150)  NOT NULL,
    cli_tel      VARCHAR(15)   NULL,
    cli_dir      VARCHAR(200)  NULL,
    cli_est      CHAR(1)       NOT NULL DEFAULT 'A',
    cli_fec_reg  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_cli_id  PRIMARY KEY (cli_id),
    CONSTRAINT uk_cli_ide UNIQUE (cli_ide),
    CONSTRAINT uk_cli_cor UNIQUE (cli_cor),
    CONSTRAINT ck_cli_est CHECK (cli_est IN ('A','I'))
);

-- ---------------------------------------------------------------------
-- Tabla 3: tbl_ser (Catálogo de Servicios)
-- Servicios de software y cloud ofrecidos por RoxMonTech.
-- ---------------------------------------------------------------------
CREATE TABLE tbl_ser (
    ser_id   INT AUTO_INCREMENT,
    ser_nom  VARCHAR(100)   NOT NULL,
    ser_des  VARCHAR(300)   NULL,
    ser_tip  VARCHAR(50)    NOT NULL,
    ser_pre  DECIMAL(10,2)  NOT NULL,
    ser_est  CHAR(1)        NOT NULL DEFAULT 'A',
    CONSTRAINT pk_ser_id  PRIMARY KEY (ser_id),
    CONSTRAINT ck_ser_tip CHECK (ser_tip IN ('Cloud','Desarrollo','Consultoria','Soporte')),
    CONSTRAINT ck_ser_pre CHECK (ser_pre >= 0),
    CONSTRAINT ck_ser_est CHECK (ser_est IN ('A','I'))
);

-- ---------------------------------------------------------------------
-- Tabla 4: tbl_con (Contratos)
-- Enlaza un cliente, un servicio contratado y el usuario responsable.
-- ---------------------------------------------------------------------
CREATE TABLE tbl_con (
    con_id       INT AUTO_INCREMENT,
    con_cli_id   INT            NOT NULL,
    con_ser_id   INT            NOT NULL,
    con_usu_id   INT            NOT NULL,
    con_fec_ini  DATE           NOT NULL,
    con_fec_fin  DATE           NULL,
    con_mon_tot  DECIMAL(10,2)  NOT NULL,
    con_est      CHAR(1)        NOT NULL DEFAULT 'A',
    CONSTRAINT pk_con_id     PRIMARY KEY (con_id),
    CONSTRAINT fk_con_cli_id FOREIGN KEY (con_cli_id) REFERENCES tbl_cli (cli_id),
    CONSTRAINT fk_con_ser_id FOREIGN KEY (con_ser_id) REFERENCES tbl_ser (ser_id),
    CONSTRAINT fk_con_usu_id FOREIGN KEY (con_usu_id) REFERENCES tbl_usu (usu_id),
    CONSTRAINT ck_con_mon    CHECK (con_mon_tot >= 0),
    CONSTRAINT ck_con_est    CHECK (con_est IN ('A','I')),
    CONSTRAINT ck_con_fechas CHECK (con_fec_fin IS NULL OR con_fec_fin >= con_fec_ini)
);

CREATE INDEX idx_con_cli_id ON tbl_con (con_cli_id);
CREATE INDEX idx_con_usu_id ON tbl_con (con_usu_id);

-- ---------------------------------------------------------------------
-- Tabla 5: tbl_tic (Tickets de Soporte)
-- Registra incidencias asociadas a un contrato, atendidas por un usuario.
-- ---------------------------------------------------------------------
CREATE TABLE tbl_tic (
    tic_id       INT AUTO_INCREMENT,
    tic_con_id   INT            NOT NULL,
    tic_usu_id   INT            NOT NULL,
    tic_asu      VARCHAR(150)   NOT NULL,
    tic_des      VARCHAR(500)   NOT NULL,
    tic_pri      CHAR(1)        NOT NULL DEFAULT 'M',
    tic_est      CHAR(1)        NOT NULL DEFAULT 'A',
    tic_fec_cre  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_tic_id     PRIMARY KEY (tic_id),
    CONSTRAINT fk_tic_con_id FOREIGN KEY (tic_con_id) REFERENCES tbl_con (con_id),
    CONSTRAINT fk_tic_usu_id FOREIGN KEY (tic_usu_id) REFERENCES tbl_usu (usu_id),
    CONSTRAINT ck_tic_pri    CHECK (tic_pri IN ('A','M','B')),
    CONSTRAINT ck_tic_est    CHECK (tic_est IN ('A','I'))
);

CREATE INDEX idx_tic_con_id ON tbl_tic (tic_con_id);
CREATE INDEX idx_tic_usu_id ON tbl_tic (tic_usu_id);

-- =====================================================================
-- Notas de convención:
-- * tic_pri: 'A' Alta, 'M' Media, 'B' Baja
-- * *_est:   'A' Activo, 'I' Inactivo (eliminación lógica, no física)
-- =====================================================================
