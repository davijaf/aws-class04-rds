# Visualizar as tabelas do MySQL (RDS) no terminal

Acesso ao RDS (schema `aws_class`) a partir do seu Mac, via cliente `mysql`.

> Os valores reais de conexão (endpoint, usuário, senha) ficam no seu **`.env`** (gitignored), na variável `SPRING_DATASOURCE_URL` + `SPRING_DATASOURCE_USERNAME` + `DB_PASSWORD`. Abaixo uso placeholders.

| Campo | Valor |
|---|---|
| Host | `<RDS-ENDPOINT>` (ex.: `database-1.xxxx.us-east-2.rds.amazonaws.com`) |
| Porta | `3306` |
| Usuário | `admin` |
| Senha | vem do `.env` (`DB_PASSWORD`) — **não** digitar/colar em arquivo |
| Schema | `aws_class` |
| TLS | `global-bundle.pem` (CA do RDS — baixar, não versionar) |

> **Rede:** o RDS precisa estar *publicly accessible* e a porta 3306 liberada pro seu IP no Security Group.

---

## 0. Baixar o CA do RDS (uma vez)
```bash
curl -o global-bundle.pem https://truststore.pki.rds.amazonaws.com/global/global-bundle.pem
```

## 1. Instalar o cliente `mysql` (uma vez)
```bash
brew install mysql-client
echo "export PATH=\"$(brew --prefix)/opt/mysql-client/bin:\$PATH\"" >> ~/.zshrc
source ~/.zshrc
mysql --version
```

## 2. Carregar a senha do `.env` (sem expor)
```bash
set -a; source .env; set +a       # exporta DB_PASSWORD, etc.
export MYSQL_PWD="$DB_PASSWORD"    # o mysql le dessa env -> sem -p e sem warning
```

## 3. Conectar (sessão interativa, TLS verificado)
```bash
mysql -h <RDS-ENDPOINT> -P 3306 -u admin \
  --ssl-ca=./global-bundle.pem --ssl-mode=VERIFY_IDENTITY \
  aws_class
```
> Sem o `.pem`: troque por `--ssl-mode=REQUIRED` e remova `--ssl-ca` (criptografa, sem verificar identidade).

## 4. Comandos para visualizar (no prompt `mysql>`)
```sql
SHOW DATABASES;               -- lista os schemas
USE aws_class;                -- entra no schema
SHOW TABLES;                  -- lista as tabelas
DESCRIBE usuario;             -- colunas e tipos
SHOW CREATE TABLE usuario\G   -- DDL completa (CREATE TABLE)
SELECT * FROM usuario;        -- todos os dados
SELECT COUNT(*) FROM usuario; -- total de linhas
SELECT * FROM usuario\G       -- saída vertical (1 campo por linha)
exit                          -- sair
```
Dica para tabelas largas (paginação horizontal com setas):
```sql
pager less -SFX
SELECT * FROM usuario;
```

## 5. One-liners (sem entrar no prompt)
```bash
# atalho reutilizável (usa o MYSQL_PWD exportado no passo 2)
alias rds='mysql -h <RDS-ENDPOINT> -u admin --ssl-mode=REQUIRED aws_class'

rds -e "SHOW TABLES;"                     # listar tabelas
rds --table -e "SELECT * FROM usuario;"   # dados em formato tabela
rds -e "DESCRIBE usuario;"                # estrutura
rds -e "SELECT * FROM usuario\\G"         # saída vertical
```

---

## Saída esperada (exemplo)
```
+----+---------+---------------------+
| id | nome    | email               |
+----+---------+---------------------+
|  1 | teste01 | teste01@example.com |
|  2 | teste02 | teste02@example.com |
|  3 | teste03 | teste03@example.com |
+----+---------+---------------------+
```

## Sem instalar nada (alternativas)
- **Via API (app no ar):** `curl http://<EC2-IP>:8080/usuarios` — ver `curls-crud-ec2.md`.
- **GUI:** TablePlus / DBeaver / MySQL Workbench apontando pro mesmo host/usuário/senha.
