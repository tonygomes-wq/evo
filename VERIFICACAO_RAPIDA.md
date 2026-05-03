# Verificação Rápida - Menu "Gerenciar Empresas"

## ✅ Correção Aplicada

O problema foi identificado e corrigido:
- **Problema**: Interface TypeScript não incluía o tipo `'system'` para roles
- **Solução**: Atualizado `rbac.ts` para incluir `type: 'user' | 'account' | 'system'`
- **Status**: Frontend reiniciado com sucesso

---

## 🚀 Próximos Passos (IMPORTANTE)

### 1. Limpar Cache do Navegador
```
Pressione: Ctrl + Shift + Delete
Selecione: Cache e Cookies
Clique: Limpar dados
```

### 2. Fazer Logout e Login Novamente
```
1. Faça logout do sistema
2. Acesse: http://localhost:5173/login
3. Login: tonygomes058@gmail.com
4. Senha: To811205ny@
```

### 3. Verificar o Menu
```
✅ Procure "Gerenciar Empresas" no menu lateral esquerdo
✅ Deve aparecer com ícone de prédio (🏢)
✅ Deve estar entre "Canais" e "Tutoriais"
```

---

## 🔍 Se o Menu Ainda Não Aparecer

### Opção 1: Limpar LocalStorage
Abra o console do navegador (F12) e execute:
```javascript
localStorage.clear()
location.reload()
```

### Opção 2: Verificar Role no Backend
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

### Opção 3: Reiniciar Frontend Novamente
```bash
docker restart evo-evo-frontend-1
```

Aguarde 30 segundos e tente novamente.

---

## 📞 Suporte

Se após seguir todos os passos o menu ainda não aparecer:

1. Tire um screenshot do menu lateral
2. Abra o console do navegador (F12)
3. Execute:
   ```javascript
   const authData = JSON.parse(localStorage.getItem('auth-storage'))
   console.log('User:', authData?.state?.currentUser)
   console.log('Role:', authData?.state?.currentUser?.role)
   ```
4. Tire um screenshot do resultado
5. Consulte: **CORRECAO_MENU_GERENCIAR_EMPRESAS.md** para troubleshooting detalhado

---

## ✅ Checklist Rápido

- [ ] Frontend reiniciado
- [ ] Cache do navegador limpo
- [ ] Logout realizado
- [ ] Login realizado novamente
- [ ] Menu "Gerenciar Empresas" visível
- [ ] Teste de criação de empresa funcionando

---

**Status**: ✅ Correção aplicada - Aguardando teste do usuário
