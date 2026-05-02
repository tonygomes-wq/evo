import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Box,
  Button,
  Card,
  CardContent,
  Typography,
  Grid,
  Alert,
  CircularProgress,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Paper,
  Chip,
  Divider
} from '@mui/material';
import {
  ArrowBack as BackIcon,
  Business as BusinessIcon,
  People as PeopleIcon,
  Assessment as StatsIcon
} from '@mui/icons-material';
import accountsService, { Account, AccountUser, AccountStats } from '../../../services/admin/accountsService';

const AccountDetails: React.FC = () => {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [account, setAccount] = useState<Account | null>(null);
  const [users, setUsers] = useState<AccountUser[]>([]);
  const [stats, setStats] = useState<AccountStats | null>(null);

  useEffect(() => {
    if (id) {
      loadAccountDetails();
    }
  }, [id]);

  const loadAccountDetails = async () => {
    if (!id) return;

    try {
      setLoading(true);
      setError(null);
      const response = await accountsService.getAccount(id);
      setAccount(response.data.account);
      setUsers(response.data.users);
      setStats(response.data.stats);
    } catch (err: any) {
      console.error('Erro ao carregar detalhes da empresa:', err);
      setError(err.response?.data?.error || 'Erro ao carregar detalhes da empresa');
    } finally {
      setLoading(false);
    }
  };

  const handleBack = () => {
    navigate('/admin/accounts');
  };

  const getRoleColor = (roleKey: string) => {
    switch (roleKey) {
      case 'super_admin':
        return 'error';
      case 'account_owner':
      case 'account_admin':
        return 'primary';
      case 'agent':
        return 'default';
      default:
        return 'default';
    }
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    );
  }

  if (error || !account) {
    return (
      <Box sx={{ p: 3 }}>
        <Alert severity="error" sx={{ mb: 3 }}>
          {error || 'Empresa não encontrada'}
        </Alert>
        <Button startIcon={<BackIcon />} onClick={handleBack}>
          Voltar
        </Button>
      </Box>
    );
  }

  return (
    <Box sx={{ p: 3 }}>
      {/* Header */}
      <Box display="flex" alignItems="center" gap={2} mb={3}>
        <Button
          startIcon={<BackIcon />}
          onClick={handleBack}
          variant="outlined"
        >
          Voltar
        </Button>
        <BusinessIcon sx={{ fontSize: 32, color: 'primary.main' }} />
        <Typography variant="h4" component="h1">
          {account.name}
        </Typography>
        <Chip
          label={account.status === 'active' ? 'Ativo' : account.status}
          color={account.status === 'active' ? 'success' : 'default'}
        />
      </Box>

      <Grid container spacing={3}>
        {/* Informações da Empresa */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" gap={1} mb={2}>
                <BusinessIcon color="primary" />
                <Typography variant="h6">Informações da Empresa</Typography>
              </Box>
              <Divider sx={{ mb: 2 }} />
              
              <Grid container spacing={2}>
                <Grid item xs={12}>
                  <Typography variant="body2" color="text.secondary">
                    Nome
                  </Typography>
                  <Typography variant="body1" fontWeight="medium">
                    {account.name}
                  </Typography>
                </Grid>

                <Grid item xs={12}>
                  <Typography variant="body2" color="text.secondary">
                    Domínio
                  </Typography>
                  <Typography variant="body1" fontWeight="medium">
                    {account.domain || '-'}
                  </Typography>
                </Grid>

                <Grid item xs={12}>
                  <Typography variant="body2" color="text.secondary">
                    Email de Suporte
                  </Typography>
                  <Typography variant="body1" fontWeight="medium">
                    {account.support_email}
                  </Typography>
                </Grid>

                <Grid item xs={12}>
                  <Typography variant="body2" color="text.secondary">
                    Idioma
                  </Typography>
                  <Typography variant="body1" fontWeight="medium">
                    {account.locale}
                  </Typography>
                </Grid>

                <Grid item xs={12}>
                  <Typography variant="body2" color="text.secondary">
                    Criado em
                  </Typography>
                  <Typography variant="body1" fontWeight="medium">
                    {new Date(account.created_at).toLocaleString('pt-BR')}
                  </Typography>
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>

        {/* Estatísticas */}
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" gap={1} mb={2}>
                <StatsIcon color="primary" />
                <Typography variant="h6">Estatísticas</Typography>
              </Box>
              <Divider sx={{ mb: 2 }} />
              
              <Grid container spacing={2}>
                <Grid item xs={12}>
                  <Box
                    sx={{
                      p: 2,
                      bgcolor: 'primary.light',
                      borderRadius: 1,
                      textAlign: 'center'
                    }}
                  >
                    <Typography variant="h3" color="primary.main">
                      {stats?.users_count || 0}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Usuários
                    </Typography>
                  </Box>
                </Grid>

                <Grid item xs={6}>
                  <Box
                    sx={{
                      p: 2,
                      bgcolor: 'success.light',
                      borderRadius: 1,
                      textAlign: 'center'
                    }}
                  >
                    <Typography variant="h4" color="success.main">
                      {stats?.agents_count || 0}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Agentes
                    </Typography>
                  </Box>
                </Grid>

                <Grid item xs={6}>
                  <Box
                    sx={{
                      p: 2,
                      bgcolor: 'info.light',
                      borderRadius: 1,
                      textAlign: 'center'
                    }}
                  >
                    <Typography variant="h4" color="info.main">
                      {stats?.conversations_count || 0}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                      Conversas
                    </Typography>
                  </Box>
                </Grid>
              </Grid>
            </CardContent>
          </Card>
        </Grid>

        {/* Usuários */}
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" gap={1} mb={2}>
                <PeopleIcon color="primary" />
                <Typography variant="h6">Usuários</Typography>
              </Box>
              <Divider sx={{ mb: 2 }} />

              {users.length === 0 ? (
                <Box textAlign="center" py={4}>
                  <Typography variant="body1" color="text.secondary">
                    Nenhum usuário encontrado
                  </Typography>
                </Box>
              ) : (
                <TableContainer component={Paper} elevation={0}>
                  <Table>
                    <TableHead>
                      <TableRow>
                        <TableCell><strong>Nome</strong></TableCell>
                        <TableCell><strong>Email</strong></TableCell>
                        <TableCell><strong>Roles</strong></TableCell>
                        <TableCell><strong>Confirmado</strong></TableCell>
                        <TableCell><strong>Criado em</strong></TableCell>
                      </TableRow>
                    </TableHead>
                    <TableBody>
                      {users.map((user) => (
                        <TableRow key={user.id} hover>
                          <TableCell>
                            <Typography variant="body1" fontWeight="medium">
                              {user.name}
                            </Typography>
                          </TableCell>
                          <TableCell>{user.email}</TableCell>
                          <TableCell>
                            <Box display="flex" gap={0.5} flexWrap="wrap">
                              {user.roles.map((role) => (
                                <Chip
                                  key={role.key}
                                  label={role.name}
                                  color={getRoleColor(role.key)}
                                  size="small"
                                />
                              ))}
                            </Box>
                          </TableCell>
                          <TableCell>
                            <Chip
                              label={user.confirmed_at ? 'Sim' : 'Não'}
                              color={user.confirmed_at ? 'success' : 'warning'}
                              size="small"
                            />
                          </TableCell>
                          <TableCell>
                            {new Date(user.created_at).toLocaleDateString('pt-BR')}
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </TableContainer>
              )}
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </Box>
  );
};

export default AccountDetails;
