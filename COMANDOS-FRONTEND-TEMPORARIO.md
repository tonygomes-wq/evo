# 🔄 COMANDOS FRONTEND - TEMPORÁRIO E REVERSÃO

## ⚡ COMANDO TEMPORÁRIO (Usar domínios Easypanel)

Use este comando para fazer o frontend funcionar **AGORA** enquanto configura o DNS:

```bash
docker exec $(docker ps -q -f name=evo-frontend) sh -c '
for file in $(find /usr/share/nginx/html -name "*.js" -type f); do
  sed -i "s|https://api.macip.com.br|https://evogo-evo-crm.ku83to.easypanel.host|g" "$file"
  sed -i "s|https://auth.macip.com.br|https://evogo-evo-auth.ku83to.easypanel.host|g" "$file"
  sed -i "s|https://core.macip.com.br|https://evogo-evo-core.ku83to.easypanel.host|g" "$file"
  sed -i "s|https://processor.macip.com.br|https://evogo-evo-processor.ku83to.easypanel.host|g" "$file"
done
echo "URLs temporárias aplicadas!"
'
```

**Resultado**: Frontend vai usar os domínios do Easypanel (*.ku83to.easypanel.host)

---

## 🔙 COMANDO DE REVERSÃO (Voltar para domínios personalizados)

Depois que o DNS estiver configurado e propagado, use este comando para reverter:

```bash
docker exec $(docker ps -q -f name=evo-frontend) sh -c '
for file in $(find /usr/share/nginx/html -name "*.js" -type f); do
  sed -i "s|https://evogo-evo-crm.ku83to.easypanel.host|https://api.macip.com.br|g" "$file"
  sed -i "s|https://evogo-evo-auth.ku83to.easypanel.host|https://auth.macip.com.br|g" "$file"
  sed -i "s|https://evogo-evo-core.ku83to.easypanel.host|https://core.macip.com.br|g" "$file"
  sed -i "s|https://evogo-evo-processor.ku83to.easypanel.host|https://processor.macip.com.br|g" "$file"
done
echo "URLs personalizadas restauradas!"
'
```

**Resultado**: Frontend volta a usar os domínios personalizados (*.macip.com.br)

---

## 📋 QUANDO USAR CADA COMANDO

### Use o TEMPORÁRIO quando:
- ✅ DNS ainda não está configurado
- ✅ Quer testar o sistema AGORA
- ✅ Domínios personalizados não resolvem

### Use a REVERSÃO quando:
- ✅ DNS foi configurado e propagou
- ✅ Domínios personalizados estão funcionando
- ✅ Testou que auth.macip.com.br, core.macip.com.br e api.macip.com.br respondem

---

## 🔍 VERIFICAR SE PRECISA REVERTER

Antes de reverter, teste se os domínios personalizados estão funcionando:

```bash
# Testar auth
curl -I https://auth.macip.com.br/api/v1/server_resources

# Testar core
curl -I https://core.macip.com.br/api/v1/custom_mcp_servers

# Testar api
curl -I https://api.macip.com.br/health
```

**Se todos responderem** (não "Could not resolve host"), pode reverter!

---

## ⚠️ IMPORTANTE

Estes comandos são **temporários** porque modificam os arquivos dentro do container.

**Se o container reiniciar**, os arquivos voltam ao estado original (com PLACEHOLDERs).

Por isso, depois que tudo funcionar, vamos **corrigir o Dockerfile** para que a substituição aconteça automaticamente.

---

## 🎯 FLUXO COMPLETO

1. **AGORA**: Execute comando TEMPORÁRIO
2. **Teste**: Frontend deve funcionar com domínios Easypanel
3. **Configure DNS**: Adicione registros A para *.macip.com.br
4. **Aguarde**: DNS propagar (5min a 24h)
5. **Teste DNS**: Execute comandos curl acima
6. **Reverta**: Execute comando de REVERSÃO
7. **Teste final**: Frontend funcionando com domínios personalizados

---

## 📝 ATALHOS

### Aplicar temporário + verificar:
```bash
docker exec $(docker ps -q -f name=evo-frontend) sh -c '
for file in $(find /usr/share/nginx/html -name "*.js" -type f); do
  sed -i "s|https://api.macip.com.br|https://evogo-evo-crm.ku83to.easypanel.host|g" "$file"
  sed -i "s|https://auth.macip.com.br|https://evogo-evo-auth.ku83to.easypanel.host|g" "$file"
  sed -i "s|https://core.macip.com.br|https://evogo-evo-core.ku83to.easypanel.host|g" "$file"
  sed -i "s|https://processor.macip.com.br|https://evogo-evo-processor.ku83to.easypanel.host|g" "$file"
done
echo "URLs temporárias aplicadas!"
' && echo "Agora recarregue o frontend (Ctrl+Shift+R)"
```

### Reverter + verificar:
```bash
docker exec $(docker ps -q -f name=evo-frontend) sh -c '
for file in $(find /usr/share/nginx/html -name "*.js" -type f); do
  sed -i "s|https://evogo-evo-crm.ku83to.easypanel.host|https://api.macip.com.br|g" "$file"
  sed -i "s|https://evogo-evo-auth.ku83to.easypanel.host|https://auth.macip.com.br|g" "$file"
  sed -i "s|https://evogo-evo-core.ku83to.easypanel.host|https://core.macip.com.br|g" "$file"
  sed -i "s|https://evogo-evo-processor.ku83to.easypanel.host|https://processor.macip.com.br|g" "$file"
done
echo "URLs personalizadas restauradas!"
' && echo "Agora recarregue o frontend (Ctrl+Shift+R)"
```

---

## 🚀 EXECUTE AGORA

**Execute o comando TEMPORÁRIO** e teste o frontend!

Depois que o DNS estiver configurado, volte aqui e execute o comando de REVERSÃO.
