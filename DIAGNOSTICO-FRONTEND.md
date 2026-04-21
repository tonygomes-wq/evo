# 🔍 DIAGNÓSTICO: FRONTEND NÃO ACESSA

## 📋 CHECKLIST DE VERIFICAÇÃO

### 1. Container está rodando?
```bash
# No Easypanel, verifique:
- Status do serviço: deve estar "Running" (verde)
- CPU/Memória: deve mostrar valores
```

### 2. Logs do container
```bash
# No Easypanel → evo-frontend → Logs
# Procure por:
- ✅ "nginx: [notice] start worker processes" → OK
- ❌ Erros de sintaxe no docker-entrypoint.sh
- ❌ Erros de permissão
- ❌ Container reiniciando constantemente
```

### 3. Variáveis de ambiente chegaram?
```bash
# No Console do Easypanel, execute:
docker exec -it $(docker ps | grep evo-frontend | awk '{print $1}') env | grep VITE

# Deve mostrar:
VITE_API_URL=https://api.macip.com.br
VITE_AUTH_API_URL=https://auth.macip.com.br
VITE_WS_URL=https://api.macip.com.br
VITE_EVOAI_API_URL=https://core.macip.com.br
VITE_AGENT_PROCESSOR_URL=https://processor.macip.com.br
VITE_TINYMCE_API_KEY=no-api-key
```

### 4. Arquivos JavaScript foram modificados?
```bash
# No Console do Easypanel, execute:
docker exec -it $(docker ps | grep evo-frontend | awk '{print $1}') sh -c "grep -r 'api.macip.com.br' /usr/share/nginx/html/*.js | head -5"

# Deve mostrar linhas com as URLs reais (não PLACEHOLDERs)
```

### 5. Nginx está servindo os arquivos?
```bash
# No navegador, acesse:
https://evogo-evo-frontend.ku83to.easypanel.host/

# Deve carregar a página HTML
# Se não carregar, problema é no Nginx ou domínio
```

### 6. Console do navegador
```
F12 → Console
Procure por:
- ❌ Erros de CORS
- ❌ Erros 404 (arquivos não encontrados)
- ❌ Erros de conexão com backends
- ❌ Erros de JavaScript
```

### 7. Network do navegador
```
F12 → Network → Recarregar página
Procure por:
- ✅ index.html → Status 200
- ✅ *.js → Status 200
- ✅ *.css → Status 200
- ❌ Requisições para backends falhando
```

---

## 🚨 PROBLEMAS COMUNS

### Problema 1: Container reiniciando
**Sintoma**: Status fica alternando entre "Starting" e "Running"

**Causa**: Erro no docker-entrypoint.sh

**Solução**: Verificar logs para ver o erro exato

---

### Problema 2: Página carrega mas não funciona
**Sintoma**: HTML/CSS carregam, mas JavaScript não funciona

**Causa**: Variáveis não foram substituídas

**Verificar**:
```bash
# Ver se os PLACEHOLDERs ainda estão lá:
docker exec -it $(docker ps | grep evo-frontend | awk '{print $1}') sh -c "grep -r 'PLACEHOLDER' /usr/share/nginx/html/*.js | head -5"

# Se mostrar resultados, as variáveis NÃO foram substituídas
```

**Solução**: 
1. Verificar se as variáveis estão configuradas no Easypanel
2. Verificar se o toggle "Criar arquivo .env" está DESLIGADO
3. Restart do container

---

### Problema 3: Erro de CORS
**Sintoma**: Console mostra "CORS policy blocked"

**Causa**: Backends não estão configurados para aceitar requisições do frontend

**Solução**: Verificar variável CORS_ORIGINS nos backends

---

### Problema 4: Erro 404 nos arquivos
**Sintoma**: Network mostra 404 para arquivos .js ou .css

**Causa**: Build não gerou os arquivos corretamente

**Solução**: Rebuild do container

---

### Problema 5: Domínio não resolve
**Sintoma**: "Site can't be reached" ou "DNS_PROBE_FINISHED_NXDOMAIN"

**Causa**: Domínio não está configurado ou DNS não propagou

**Solução**: Verificar configuração de domínios no Easypanel

---

## 🔧 COMANDOS DE DIAGNÓSTICO

### Ver logs em tempo real:
```bash
# No Easypanel → evo-frontend → Logs
# Ou via CLI:
docker logs -f $(docker ps | grep evo-frontend | awk '{print $1}')
```

### Entrar no container:
```bash
docker exec -it $(docker ps | grep evo-frontend | awk '{print $1}') sh
```

### Ver arquivos servidos pelo Nginx:
```bash
docker exec -it $(docker ps | grep evo-frontend | awk '{print $1}') ls -la /usr/share/nginx/html/
```

### Ver conteúdo de um arquivo JS:
```bash
docker exec -it $(docker ps | grep evo-frontend | awk '{print $1}') head -100 /usr/share/nginx/html/assets/*.js
```

### Testar Nginx internamente:
```bash
docker exec -it $(docker ps | grep evo-frontend | awk '{print $1}') wget -O- http://localhost/
```

---

## 📊 MATRIZ DE DIAGNÓSTICO

| Sintoma | Causa Provável | Verificar |
|---------|----------------|-----------|
| Container não inicia | Erro no entrypoint | Logs do container |
| Página não carrega | Nginx/Domínio | Status do container, domínios |
| Página carrega vazia | Build incorreto | Arquivos em /usr/share/nginx/html |
| Erros no console | Variáveis não substituídas | grep PLACEHOLDER nos .js |
| Erro de conexão | URLs incorretas | grep api.macip.com.br nos .js |
| Erro de CORS | Backend não configurado | Logs dos backends |

---

## 🎯 PRÓXIMOS PASSOS

Para eu poder ajudar melhor, preciso que você me envie:

1. **Logs do container evo-frontend** (últimas 50 linhas)
2. **Screenshot do Console do navegador** (F12 → Console)
3. **Screenshot da aba Network** (F12 → Network)
4. **Status do container** (Running? Restarting?)
5. **Resultado do comando**:
   ```bash
   docker exec -it $(docker ps | grep evo-frontend | awk '{print $1}') env | grep VITE
   ```

Com essas informações, posso identificar exatamente o que está errado! 🔍
