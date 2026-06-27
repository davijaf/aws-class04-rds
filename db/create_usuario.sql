-- Tabela 'usuario' em database-1
-- Espelha a entity com.aws.class3.sql.entity.Usuario:
--   id    -> Long  + @GeneratedValue(IDENTITY)  -> BIGINT AUTO_INCREMENT (PK)
--   nome  -> String + @Column(nullable=false)    -> VARCHAR(255) NOT NULL
--   email -> String + @Column(nullable=false, unique=true) -> VARCHAR(255) NOT NULL UNIQUE
--
-- Schema 'aws_class' para casar com o spring.datasource.url (/aws_class).

CREATE DATABASE IF NOT EXISTS aws_class;
USE aws_class;

CREATE TABLE IF NOT EXISTS usuario (
    id    BIGINT       NOT NULL AUTO_INCREMENT,
    nome  VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT uk_usuario_email UNIQUE (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
