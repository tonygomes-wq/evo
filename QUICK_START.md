# Quick Start - Multi-Tenant Admin

## 🚀 Teste Rápido (5 minutos)

### 1. Acesse o Sistema
```
URL: http://localhost:5173/login
```

### 2. Faça Login
```
Email: tonygomes058@gmail.com
Senha: To811205ny@
```

### 3. Procure no Menu
- Procure o item **"Gerenciar Empresas"** no menu lateral esquerdo
- Ícone: 🏢 (prédio)

### 4. Crie uma Empresa
1. Clique em **"Nova Empresa"**
2. Preencha:
   - **Nome**: Empresa Teste 1
   - **Email**: suporte@teste1.com
   - **Admin Nome**: Admin Teste
   - **Admin Email**: admin@teste1.com
   - **Senha**: Senha123!
3. Clique em **"Criar Empresa"**

### 5. Verifique
- ✅ Empresa aparece na listagem
- ✅ Clique em "Ver Detalhes" para ver mais informações

---

## 📊 Status

| Item | Status |
|------|--------|
| Backend | ✅ Completo |
| Database | ✅ Completo |
| Frontend | ✅ Completo |
| Menu | ✅ Completo |
| Traduções | ✅ Completo |
| Serviços | ✅ Rodando |

---

## 📚 Documentação

- **Guia de Testes**: `TESTE_MULTI_TENANT_ADMIN.md`
- **Documentação Técnica**: `IMPLEMENTACAO_MULTI_TENANT_COMPLETA.md`
- **Resumo**: `RESUMO_IMPLEMENTACAO_FINAL.md`

---

## 🆘 Problemas?

### Menu não aparece?
```bash
# Verificar role
docker exec -it evo-evo-auth-1 bundle exec rails runner "
  user = User.find_by(email: 'tonygomes058@gmail.com')
  puts user.roles.pluck(:key).join(', ')
"

# Reiniciar frontend
docker restart evo-evo-frontend-1
```

### Erro 403?
- Verifique se está logado como super_admin
- Faça logout e login novamente

### Página em branco?
- Abra o console do navegador (F12)
- Verifique erros JavaScript
- Reinicie o frontend

---

## ✅ Checklist Rápido

- [ ] Login bem-sucedido
- [ ] Menu "Gerenciar Empresas" visível
- [ ] Página de listagem carrega
- [ ] Formulário de criação funciona
- [ ] Empresa criada aparece na lista
- [ ] Detalhes da empresa são exibidos

---

**Tudo funcionando?** 🎉  
**Consulte a documentação completa para mais detalhes!**
