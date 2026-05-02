import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Box,
  Button,
  Card,
  CardContent,
  TextField,
  Typography,
  Grid,
  Alert,
  CircularProgress,
  Divider,
  Paper
} from '@mui/material';
import {
  ArrowBack as BackIcon,
  Save as SaveIcon,
  Business as BusinessIcon,
  Person as PersonIcon
} from '@mui/icons-material';
import accountsService, { CreateAccountData } from '../../../services/admin/accountsService';

const CreateAccount: React.FC = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState<string[]>([]);
  const [formData, setFormData] = useState<CreateAccountData>({
    account: {
      name: '',
      domain: '',
      support_email: '',
      locale: 'pt-BR',
      status: 'active'
    },
    admin: {
      name: '',
      email: '',
      password: '',
      password_confirmation: ''
    }
  });

  const handleChange = (section: 'account' | 'admin', field: string, value: string) => {
    setFormData(prev => ({
      ...prev,
      [section]: {
        ...prev[section],
        [field]: value
      }
    }));
  };

  const validateForm = (): boolean => {
    const newErrors: string[] = [];

    // Validar dados da empresa
    if (!formData.account.name.trim()) {
      newErrors.push('Nome da empresa é obrigatório');
    }
    if (!formData.account.support_email.trim()) {
      newErrors.push('Email de suporte é obrigatório');
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.account.support_email)) {
      newErrors.push('Email de suporte inválido');
    }

    // Validar dados do administrador
    if (!formData.admin.name.trim()) {
      newErrors.push('Nome do administrador é obrigatório');
    }
    if (!formData.admin.email.trim()) {
      newErrors.push('Email do administrador é obrigatório');
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.admin.email)) {
      newErrors.push('Email do administrador inválido');
    }
    if (!formData.admin.password) {
      newErrors.push('Senha é obrigatória');
    } else if (formData.admin.password.length < 8) {
      newErrors.push('Senha deve ter no mínimo 8 caracteres');
    }
    if (formData.admin.password !== formData.admin.password_confirmation) {
      newErrors.push('As senhas não coincidem');
    }

    setErrors(newErrors);
    return newErrors.length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    try {
      setLoading(true);
      setErrors([]);
      
      const response = await accountsService.createAccount(formData);
      
      if (response.success) {
        alert('Empresa criada com sucesso!');
        navigate('/admin/accounts');
      } else {
        setErrors([response.message || 'Erro ao criar empresa']);
      }
    } catch (err: any) {
      console.error('Erro ao criar empresa:', err);
      const errorMessage = err.response?.data?.errors || 
                          err.response?.data?.error || 
                          ['Erro ao criar empresa'];
      setErrors(Array.isArray(errorMessage) ? errorMessage : [errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = () => {
    navigate('/admin/accounts');
  };

  return (
    <Box sx={{ p: 3 }}>
      {/* Header */}
      <Box display="flex" alignItems="center" gap={2} mb={3}>
        <Button
          startIcon={<BackIcon />}
          onClick={handleCancel}
          variant="outlined"
        >
          Voltar
        </Button>
        <Typography variant="h4" component="h1">
          Nova Empresa
        </Typography>
      </Box>

      {/* Error Alert */}
      {errors.length > 0 && (
        <Alert severity="error" sx={{ mb: 3 }} onClose={() => setErrors([])}>
          {errors.map((error, index) => (
            <div key={index}>{error}</div>
          ))}
        </Alert>
      )}

      {/* Form */}
      <form onSubmit={handleSubmit}>
        <Grid container spacing={3}>
          {/* Dados da Empresa */}
          <Grid item xs={12}>
            <Card>
              <CardContent>
                <Box display="flex" alignItems="center" gap={1} mb={3}>
                  <BusinessIcon color="primary" />
                  <Typography variant="h6">Dados da Empresa</Typography>
                </Box>
                
                <Grid container spacing={2}>
                  <Grid item xs={12} md={6}>
                    <TextField
                      fullWidth
                      required
                      label="Nome da Empresa"
                      value={formData.account.name}
                      onChange={(e) => handleChange('account', 'name', e.target.value)}
                      placeholder="Ex: Minha Empresa Ltda"
                    />
                  </Grid>

                  <Grid item xs={12} md={6}>
                    <TextField
                      fullWidth
                      label="Domínio"
                      value={formData.account.domain}
                      onChange={(e) => handleChange('account', 'domain', e.target.value)}
                      placeholder="exemplo.com"
                      helperText="Opcional"
                    />
                  </Grid>

                  <Grid item xs={12} md={6}>
                    <TextField
                      fullWidth
                      required
                      type="email"
                      label="Email de Suporte"
                      value={formData.account.support_email}
                      onChange={(e) => handleChange('account', 'support_email', e.target.value)}
                      placeholder="suporte@exemplo.com"
                    />
                  </Grid>

                  <Grid item xs={12} md={6}>
                    <TextField
                      fullWidth
                      select
                      label="Idioma"
                      value={formData.account.locale}
                      onChange={(e) => handleChange('account', 'locale', e.target.value)}
                      SelectProps={{
                        native: true,
                      }}
                    >
                      <option value="pt-BR">Português (Brasil)</option>
                      <option value="en">English</option>
                      <option value="es">Español</option>
                    </TextField>
                  </Grid>
                </Grid>
              </CardContent>
            </Card>
          </Grid>

          {/* Dados do Administrador */}
          <Grid item xs={12}>
            <Card>
              <CardContent>
                <Box display="flex" alignItems="center" gap={1} mb={3}>
                  <PersonIcon color="primary" />
                  <Typography variant="h6">Administrador da Empresa</Typography>
                </Box>
                
                <Grid container spacing={2}>
                  <Grid item xs={12} md={6}>
                    <TextField
                      fullWidth
                      required
                      label="Nome do Administrador"
                      value={formData.admin.name}
                      onChange={(e) => handleChange('admin', 'name', e.target.value)}
                      placeholder="João Silva"
                    />
                  </Grid>

                  <Grid item xs={12} md={6}>
                    <TextField
                      fullWidth
                      required
                      type="email"
                      label="Email"
                      value={formData.admin.email}
                      onChange={(e) => handleChange('admin', 'email', e.target.value)}
                      placeholder="admin@exemplo.com"
                    />
                  </Grid>

                  <Grid item xs={12} md={6}>
                    <TextField
                      fullWidth
                      required
                      type="password"
                      label="Senha"
                      value={formData.admin.password}
                      onChange={(e) => handleChange('admin', 'password', e.target.value)}
                      helperText="Mínimo 8 caracteres"
                    />
                  </Grid>

                  <Grid item xs={12} md={6}>
                    <TextField
                      fullWidth
                      required
                      type="password"
                      label="Confirmar Senha"
                      value={formData.admin.password_confirmation}
                      onChange={(e) => handleChange('admin', 'password_confirmation', e.target.value)}
                    />
                  </Grid>
                </Grid>
              </CardContent>
            </Card>
          </Grid>

          {/* Actions */}
          <Grid item xs={12}>
            <Paper sx={{ p: 2 }}>
              <Box display="flex" justifyContent="flex-end" gap={2}>
                <Button
                  variant="outlined"
                  onClick={handleCancel}
                  disabled={loading}
                >
                  Cancelar
                </Button>
                <Button
                  type="submit"
                  variant="contained"
                  color="primary"
                  startIcon={loading ? <CircularProgress size={20} /> : <SaveIcon />}
                  disabled={loading}
                >
                  {loading ? 'Criando...' : 'Criar Empresa'}
                </Button>
              </Box>
            </Paper>
          </Grid>
        </Grid>
      </form>
    </Box>
  );
};

export default CreateAccount;
