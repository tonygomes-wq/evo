import React, { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  Badge
} from '@evoapi/design-system';
import {
  ArrowLeft,
  Building2,
  Mail,
  Globe,
  Calendar
} from 'lucide-react';
import accountsService, { Account } from '@/services/admin/accountsService';
import { toast } from 'sonner';
import { BaseHeader } from '@/components/base';

const AccountDetails: React.FC = () => {
  const navigate = useNavigate();
  const { id } = useParams<{ id: string }>();
  const [account, setAccount] = useState<Account | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (id) {
      loadAccount(id);
    }
  }, [id]);

  const loadAccount = async (accountId: string) => {
    try {
      setLoading(true);
      const data = await accountsService.getAccount(accountId);
      setAccount(data);
    } catch (error: any) {
      toast.error('Erro ao carregar empresa: ' + (error.message || 'Erro desconhecido'));
      navigate('/admin/accounts');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-full">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    );
  }

  if (!account) {
    return null;
  }

  return (
    <div className="flex flex-col h-full">
      <BaseHeader
        title={account.name}
        subtitle="Detalhes da empresa"
        secondaryActions={[{
          label: 'Voltar',
          icon: <ArrowLeft className="h-4 w-4" />,
          onClick: () => navigate('/admin/accounts'),
          variant: 'outline'
        }]}
      />

      <div className="flex-1 overflow-auto p-6">
        <div className="max-w-4xl mx-auto space-y-6">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>Informações da Empresa</CardTitle>
                <Badge variant={account.status === 'active' ? 'default' : 'secondary'}>
                  {account.status === 'active' ? 'Ativa' : 'Inativa'}
                </Badge>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Building2 className="h-4 w-4" />
                    <span>Nome</span>
                  </div>
                  <p className="font-medium">{account.name}</p>
                </div>

                {account.domain && (
                  <div className="space-y-2">
                    <div className="flex items-center gap-2 text-sm text-muted-foreground">
                      <Globe className="h-4 w-4" />
                      <span>Domínio</span>
                    </div>
                    <p className="font-medium">{account.domain}</p>
                  </div>
                )}

                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Mail className="h-4 w-4" />
                    <span>Email de Suporte</span>
                  </div>
                  <p className="font-medium">{account.support_email}</p>
                </div>

                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Globe className="h-4 w-4" />
                    <span>Idioma</span>
                  </div>
                  <p className="font-medium">{account.locale}</p>
                </div>

                <div className="space-y-2">
                  <div className="flex items-center gap-2 text-sm text-muted-foreground">
                    <Calendar className="h-4 w-4" />
                    <span>Data de Criação</span>
                  </div>
                  <p className="font-medium">
                    {new Date(account.created_at).toLocaleDateString('pt-BR')}
                  </p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};

export default AccountDetails;
