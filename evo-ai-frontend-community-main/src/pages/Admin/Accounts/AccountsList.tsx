import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Box, 
  Button, 
  Card, 
  CardContent, 
  Typography, 
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  IconButton,
  CircularProgress,
  Alert
} from '@mui/material';
import { 
  Add as AddIcon, 
  Visibility as ViewIcon,
  Business as BusinessIcon
} from '@mui/icons-material';
import accountsService, { Account } from '../../../services/admin/accountsService';

const AccountsList: React.FC = () => {
  const navigate = useNavigate();
  const [accounts, setAccounts] = useState<Account[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadAccounts();
  }, []);

  const loadAccounts = async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await accountsService.getAccounts();
      setAccounts(response.data);
    } catch (err: any) {
      console.error('Erro ao carregar empresas:', err);
      setError(err.response?.data?.error || 'Erro ao carregar empresas');
    } finally {
      setLoading(false);
    }
  };

  const handleCreateAccount = () => {
    navigate('/admin/accounts/new');
  };

  const handleViewAccount = (accountId: string) => {
    navigate(`/admin/accounts/${accountId}`);
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'success';
      case 'inactive':
        return 'default';
      case 'suspended':
        return 'error';
      default:
        return 'default';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'inactive':
        return 'Inativo';
      case 'suspended':
        return 'Suspenso';
      default:
        return status;
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      {/* Header */}
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Box display="flex" alignItems="center" gap={2}>
          <BusinessIcon sx={{ fontSize: 32, color: 'primary.main' }} />
          <Typography variant="h4" component="h1">
            Gerenciar Empresas
          </Typography>
        </Box>
        <Button
          variant="contained"
          color="primary"
          startIcon={<AddIcon />}
          onClick={handleCreateAccount}
        >
          Nova Empresa
        </Button>
      </Box>

      {/* Error Alert */}
      {error && (
        <Alert severity="error" sx={{ mb: 3 }} onClose={() => setError(null)}>
          {error}
        </Alert>
      )}

      {/* Accounts Table */}
      <Card>
        <CardContent>
          {accounts.length === 0 ? (
            <Box textAlign="center" py={4}>
              <BusinessIcon sx={{ fontSize: 64, color: 'text.secondary', mb: 2 }} />
              <Typography variant="h6" color="text.secondary" gutterBottom>
                Nenhuma empresa cadastrada
              </Typography>
              <Typography variant="body2" color="text.secondary" mb={3}>
                Crie sua primeira empresa para começar
              </Typography>
              <Button
                variant="contained"
                color="primary"
                startIcon={<AddIcon />}
                onClick={handleCreateAccount}
              >
                Criar Primeira Empresa
              </Button>
            </Box>
          ) : (
            <TableContainer component={Paper} elevation={0}>
              <Table>
                <TableHead>
                  <TableRow>
                    <TableCell><strong>Nome</strong></TableCell>
                    <TableCell><strong>Domínio</strong></TableCell>
                    <TableCell><strong>Email de Suporte</strong></TableCell>
                    <TableCell><strong>Status</strong></TableCell>
                    <TableCell><strong>Criado em</strong></TableCell>
                    <TableCell align="center"><strong>Ações</strong></TableCell>
                  </TableRow>
                </TableHead>
                <TableBody>
                  {accounts.map((account) => (
                    <TableRow key={account.id} hover>
                      <TableCell>
                        <Typography variant="body1" fontWeight="medium">
                          {account.name}
                        </Typography>
                      </TableCell>
                      <TableCell>{account.domain || '-'}</TableCell>
                      <TableCell>{account.support_email}</TableCell>
                      <TableCell>
                        <Chip
                          label={getStatusLabel(account.status)}
                          color={getStatusColor(account.status)}
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        {new Date(account.created_at).toLocaleDateString('pt-BR')}
                      </TableCell>
                      <TableCell align="center">
                        <IconButton
                          color="primary"
                          size="small"
                          onClick={() => handleViewAccount(account.id)}
                          title="Ver Detalhes"
                        >
                          <ViewIcon />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </TableContainer>
          )}
        </CardContent>
      </Card>
    </Box>
  );
};

export default AccountsList;
