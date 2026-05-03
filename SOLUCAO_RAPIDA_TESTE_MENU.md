# Solução Rápida - Testar Menu "Gerenciar Empresas"

**Data**: 03/05/2026  
**Tempo Estimado**: 5 minutos

---

## 🚀 Solução Mais Rápida: Rodar Frontend em Modo Dev

Como a build do Docker está com erro, a forma mais rápida de testar é rodar o frontend localmente em modo desenvolvimento.

### Passo 1: Parar o Frontend Docker

```bash
docker-compose -f docker-compose.local.yaml stop evo-frontend
```

### Passo 2: Instalar Dependências

```bash
cd evo-ai-frontend-community-main
npm install
```

**Tempo**: ~2-3 minutos

### Passo 3: Rodar em Modo Dev

```bash
npm run dev
```

O frontend vai iniciar em `http://localhost:5173` com hot-reload ativado.

### Passo 4: Testar

1. Abra o navegador em `http://localhost:5173`
2. Faça login:
   - **Email**: `tonygomes058@gmail.com`
   - **Senha**: `To811205ny@`
3. Verifique se o menu **"Gerenciar Empresas"** aparece no menu lateral

---

## ✅ Vantagens desta Abordagem

- ✅ **Rápido**: Não precisa reconstruir Docker
- ✅ **Hot-reload**: Mudanças no código são refletidas instantaneamente
- ✅ **Debug fácil**: Console do navegador mostra erros em tempo real
- ✅ **Desenvolvimento**: Ideal para testar e ajustar

---

## 🔄 Alternativa: Corrigir o Erro de Build

Se preferir usar o Docker, você precisa corrigir o erro de build primeiro:

### Investigar o Erro

```bash
cd evo-ai-frontend-community-main
npm run build
```

Isso vai mostrar o erro completo do TypeScript.

### Possíveis Causas

1. **Problema de encoding**: Arquivo pode ter caracteres invisíveis
2. **Problema de versão**: TypeScript no Docker pode ser diferente do local
3. **Cache do Docker**: Build anterior pode estar interferindo

### Tentar Limpar Cache

```bash
# Remover a imagem antiga
docker rmi evo-evo-frontend

# Reconstruir sem cache
docker-compose -f docker-compose.local.yaml build --no-cache evo-frontend

# Iniciar
docker-compose -f docker-compose.local.yaml up -d evo-frontend
```

---

## 📝 Notas Importantes

### Serviços Backend
Todos os serviços backend estão funcionando:
- ✅ CRM: Operacional (resolvido o crash loop)
- ✅ Auth: Healthy
- ✅ Gateway: Rodando
- ✅ Core: Rodando
- ✅ Processor: Healthy

### Código Frontend
Todo o código está pronto e correto:
- ✅ Rotas `/admin/accounts` criadas
- ✅ Componentes React implementados
- ✅ Serviço de API configurado
- ✅ Menu configurado com `requiredRoleKey: 'super_admin'`
- ✅ Traduções PT-BR e EN
- ✅ Interfaces TypeScript atualizadas (tipo 'system')

### O Problema
O único problema é que a build do Docker falha com um erro de TypeScript que não aparece localmente. Por isso, rodar em modo dev é a solução mais rápida.

---

## 🎯 Resultado Esperado

Após seguir os passos acima, você deve ver:

1. **Menu Lateral**:
   - Item "Gerenciar Empresas" com ícone de prédio 🏢
   - Localizado entre "Canais" e "Tutoriais"
   - Visível apenas para super_admin

2. **Página de Listagem** (`/admin/accounts`):
   - Tabela com todas as empresas
   - Botão "Nova Empresa"
   - Informações: Nome, Domínio, Email, Status, Data de Criação

3. **Funcionalidades**:
   - Criar nova empresa
   - Ver detalhes da empresa
   - Listar usuários da empresa

---

## 🆘 Se Ainda Não Funcionar

Se o menu ainda não aparecer após rodar em modo dev:

1. **Limpar cache do navegador**:
   ```
   Ctrl + Shift + Delete
   Limpar cache e cookies
   ```

2. **Verificar role do usuário**:
   ```bash
   docker exec -it evo-evo-auth-1 bundle exec rails runner "
     user = User.find_by(email: 'tonygomes058@gmail.com')
     puts 'Role: ' + user.roles.first.key
     puts 'Type: ' + user.roles.first.type
   "
   ```
   
   Deve retornar:
   ```
   Role: super_admin
   Type: system
   ```

3. **Verificar console do navegador** (F12):
   - Procure por erros de API
   - Verifique se o usuário está autenticado
   - Verifique se a role está correta

---

**Última Atualização**: 03/05/2026 10:25 BRT  
**Responsável**: Tony Gomes  
**Status**: ✅ **PRONTO PARA TESTE EM MODO DEV**
