import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  Button,
  Input,
  Label,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue
} from '@evoapi/design-system';
import {
  ArrowLeft,
  Save,
  Building2,
  User
} from 'lucide-react';
import accountsService from '@/services/admin/accountsService';
import { toast } from 'sonner';
import { BaseHeader } from '@/components/base';

const CreateAccount: React.FC = () => {
  const navigate = useNavigate();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    account: {
      name: '',
      domain: '',
      support_email: '',
      locale: 'pt-BR'
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

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (formData.admin.password !== formData.admin.password_confirmation) {
      toast.error('As senhas não coincidem');
      return;
    }

    if (formData.admin.password.length < 8) {
      toast.error('A senha deve ter no mínimo 8 caracteres');
      return;
    }

    try {
      setLoading(true);
      await accountsService.createAccount(formData);
      toast.success('Empresa criada com sucesso!');
      navigate('/admin/accounts');
    } catch (error: any) {
      toast.error('Erro ao criar empresa: ' + (error.message || 'Erro desconhecido'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col h-full">
      <BaseHeader
        title="Nova Empresa"
        subtitle="Crie uma nova empresa no sistema"
        secondaryActions={[{
          label: 'Voltar',
          icon: <ArrowLeft className="h-4 w-4" />,
          onClick: () => navigate('/admin/accounts'),
          variant: 'outline'
        }]}
      />

      <div className="flex-1 overflow-auto p-6">
        <form onSubmit={handleSubmit} className="max-w-4xl mx-auto space-y-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Building2 className="h-5 w-5" />
                Dados da Empresa
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="account-name">Nome da Empresa *</Label>
                  <Input
                    id="account-name"
                    required
                    value={formData.account.name}
                    onChange={(e) => handleChange('account', 'name', e.target.value)}
                    placeholder="Ex: Minha Empresa Ltda"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="account-domain">Domínio</Label>
                  <Input
                    id="account-domain"
                    value={formData.account.domain}
                    onChange={(e) => handleChange('account', 'domain', e.target.value)}
                    placeholder="exemplo.com"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="account-email">Email de Suporte *</Label>
                  <Input
                    id="account-email"
                    type="email"
                    required
                    value={formData.account.support_email}
                    onChange={(e) => handleChange('account', 'support_email', e.target.value)}
                    placeholder="suporte@exemplo.com"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="account-locale">Idioma *</Label>
                  <Select
                    value={formData.account.locale}
                    onValueChange={(value) => handleChange('account', 'locale', value)}
                  >
                    <SelectTrigger id="account-locale">
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="pt-BR">Português (Brasil)</SelectItem>
                      <SelectItem value="en">English</SelectItem>
                      <SelectItem value="es">Español</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <User className="h-5 w-5" />
                Administrador da Empresa
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="admin-name">Nome *</Label>
                  <Input
                    id="admin-name"
                    required
                    value={formData.admin.name}
                    onChange={(e) => handleChange('admin', 'name', e.target.value)}
                    placeholder="João Silva"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="admin-email">Email *</Label>
                  <Input
                    id="admin-email"
                    type="email"
                    required
                    value={formData.admin.email}
                    onChange={(e) => handleChange('admin', 'email', e.target.value)}
                    placeholder="admin@exemplo.com"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="admin-password">Senha *</Label>
                  <Input
                    id="admin-password"
                    type="password"
                    required
                    value={formData.admin.password}
                    onChange={(e) => handleChange('admin', 'password', e.target.value)}
                    placeholder="Mínimo 8 caracteres"
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="admin-password-confirmation">Confirmar Senha *</Label>
                  <Input
                    id="admin-password-confirmation"
                    type="password"
                    required
                    value={formData.admin.password_confirmation}
                    onChange={(e) => handleChange('admin', 'password_confirmation', e.target.value)}
                  />
                </div>
              </div>
            </CardContent>
          </Card>

          <div className="flex justify-end gap-2">
            <Button
              type="button"
              variant="outline"
              onClick={() => navigate('/admin/accounts')}
              disabled={loading}
            >
              Cancelar
            </Button>
            <Button type="submit" disabled={loading}>
              {loading ? (
                <>
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2" />
                  Criando...
                </>
              ) : (
                <>
                  <Save className="h-4 w-4 mr-2" />
                  Criar Empresa
                </>
              )}
            </Button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default CreateAccount;
