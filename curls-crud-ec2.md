# CRUD via curl — class04_task01 na EC2

API Spring Boot (`class3`) implantada na EC2 **`ec2-class01`**, conectada ao RDS MySQL **`database-1`** (schema `aws_class`, tabela `usuario`).

- **Base URL (EC2):** `http://<EC2-IP>:8080`
- **Service:** `class04-task01.service` (systemd, porta 8080, `enabled` — sobe no boot)
- **Endpoints:** `/health`, `/actuator/health`, `/usuarios` (CRUD)

> Exporte a base pra reusar nos comandos:
> ```bash
> export EC2=http://<EC2-IP>:8080
> ```

---

## Health

### Health (controller custom)
```bash
curl $EC2/health
```
```json
{"status":"UP","timestamp":"1782517088956"}
```

### Health (Spring Actuator)
```bash
curl $EC2/actuator/health
```
```json
{"status":"UP"}
```

---

## CRUD de usuários

### Listar todos
```bash
curl $EC2/usuarios
# formatado:
curl -s $EC2/usuarios | python3 -m json.tool
```
```json
[
  {"id":1,"nome":"teste01","email":"teste01@example.com"},
  {"id":2,"nome":"teste02","email":"teste02@example.com"},
  {"id":3,"nome":"teste03","email":"teste03@example.com"}
]
```

### Buscar por id
```bash
curl $EC2/usuarios/1
```
```json
{"id":1,"nome":"teste01","email":"teste01@example.com"}
```

### Criar (POST)
```bash
curl -X POST $EC2/usuarios \
  -H 'Content-Type: application/json' \
  -d '{"nome":"teste04","email":"teste04@example.com"}'
```
```json
{"id":4,"nome":"teste04","email":"teste04@example.com"}
```
> `email` é `UNIQUE` — repetir o mesmo email viola a constraint (erro 500).

### Deletar por id
```bash
curl -i -X DELETE $EC2/usuarios/4
```
```
HTTP/1.1 204 No Content
```

### Id inexistente
```bash
curl -i $EC2/usuarios/999
```
```
HTTP/1.1 404 Not Found
```

---

## Operação do serviço (na EC2)
```bash
ssh -i ~/Downloads/<sua-chave>.pem ubuntu@<EC2-IP>

sudo systemctl status class04-task01      # status
sudo journalctl -u class04-task01 -f      # logs ao vivo
sudo systemctl restart class04-task01     # reiniciar
```

---

## Arquitetura
```
curl → EC2 ec2-class01 (<EC2-IP>:8080 · systemd class04-task01)
        └─ Spring Boot class3 (Java 21)
            └─ JDBC TLS (sslMode=REQUIRED) → RDS database-1 (endpoint público)
                └─ MySQL 8.4 → schema aws_class → tabela usuario
```

> ⚠️ **Lab — lembrar de reverter ao encerrar:** o RDS está *publicly accessible* com a 3306 liberada pro IP do laptop + da EC2, e a 8080 da EC2 está aberta a `0.0.0.0/0`. Para não gerar risco/custo: RDS → *Not publicly accessible*, remover as regras de SG, e parar o `database-1` / `class04-task01` se não for usar.
