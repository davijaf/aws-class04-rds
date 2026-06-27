# class04_task01 — API RDS (Spring Boot + MySQL na AWS)

Lab do treinamento **Assurance — Java → AWS**. API REST em **Spring Boot 3 / Java 21** que faz CRUD de `usuario` num **RDS MySQL**, implantada em **EC2**.

> Derivado de `RobertoMVB/aws-class` (branch `develop`), **isolado para a parte de RDS** — removidos os módulos de S3, DynamoDB, SQS e SNS, mantendo apenas RDS + health.

## Stack
- **Java 21**, **Spring Boot 3.5** — Web, Data JPA, Actuator
- **MySQL** (AWS RDS) via `mysql-connector-j`
- Deploy: **EC2** (systemd service) → **RDS** (endpoint público, TLS)

## Estrutura
```
src/main/java/com/aws/class3/
├── Class3Application.java          # bootstrap Spring Boot
├── health/controller/             # GET /health
└── sql/                           # RDS: entity + repository + controller (CRUD /usuarios)
src/main/resources/application.properties
db/create_usuario.sql              # DDL da tabela usuario
.env.example                       # template de segredos (copiar p/ .env)
curls-crud-ec2.md                  # exemplos de curl (CRUD)
mysql-cli.md                       # acessar o MySQL pelo terminal
class04_task01.postman_collection.json
```

## Endpoints
| Método | Rota | Descrição |
|---|---|---|
| GET | `/health` | health check (controller) |
| GET | `/actuator/health` | health (Spring Actuator) |
| GET | `/usuarios` | lista todos |
| GET | `/usuarios/{id}` | busca por id (404 se não existe) |
| POST | `/usuarios` | cria — body `{"nome":"...","email":"..."}` |
| DELETE | `/usuarios/{id}` | remove (204) |

## Modelo de dados
`usuario`: `id` (BIGINT, PK, auto-increment) · `nome` (VARCHAR, NOT NULL) · `email` (VARCHAR, NOT NULL, UNIQUE).
DDL em [`db/create_usuario.sql`](db/create_usuario.sql).

## Configuração (segredos fora do código)
A senha do banco fica no `.env` (**gitignored**). Crie a partir do template:
```bash
cp .env.example .env    # e preencha DB_PASSWORD
```
A app resolve `${DB_PASSWORD}` do ambiente. Datasource via variáveis:
`SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `DB_PASSWORD`.

## Rodar local
```bash
set -a; source .env; set +a
export SPRING_DATASOURCE_URL="jdbc:mysql://<RDS-ENDPOINT>:3306/aws_class?sslMode=REQUIRED"
export SPRING_DATASOURCE_USERNAME="admin"
mvn spring-boot:run
curl http://localhost:8080/usuarios
```

## Build
```bash
mvn clean package -DskipTests   # -> target/class3-0.0.1-SNAPSHOT.jar
```

## Deploy na EC2
A app roda como **systemd service** (`class04-task01.service`) na porta **8080**, conectando ao RDS pelo endpoint público com `sslMode=REQUIRED`. Passo a passo de testes e operação em [`curls-crud-ec2.md`](curls-crud-ec2.md).

```bash
# build -> envia jar -> systemd (resumo; detalhes nos .md)
scp -i <chave.pem> target/class3-0.0.1-SNAPSHOT.jar ubuntu@<EC2-IP>:/home/ubuntu/class04_task01/app.jar
ssh -i <chave.pem> ubuntu@<EC2-IP> 'sudo systemctl restart class04-task01'
```

## Documentos do lab
- [`db/create_usuario.sql`](db/create_usuario.sql) — DDL da tabela
- [`curls-crud-ec2.md`](curls-crud-ec2.md) — testes da API via curl
- [`mysql-cli.md`](mysql-cli.md) — acessar o MySQL no terminal
- [`class04_task01.postman_collection.json`](class04_task01.postman_collection.json) — collection Postman (importável / `newman`)

---
> ⚠️ **Lab AWS:** ao encerrar, reverter os recursos (RDS *Not publicly accessible*, remover regras de Security Group, parar instâncias) para não gerar custo/risco.
