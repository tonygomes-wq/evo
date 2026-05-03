import { api } from '../index';

export interface Account {
  id: string;
  name: string;
  domain: string;
  support_email: string;
  locale: string;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface AccountUser {
  id: string;
  name: string;
  email: string;
  confirmed_at: string;
  roles: Array<{
    key: string;
    name: string;
  }>;
  created_at: string;
  updated_at: string;
}

export interface CreateAccountData {
  account: {
    name: string;
    domain?: string;
    support_email: string;
    locale?: string;
    status?: string;
  };
  admin: {
    name: string;
    email: string;
    password: string;
    password_confirmation: string;
  };
}

export interface AccountStats {
  users_count: number;
  agents_count: number;
  conversations_count: number;
}

export interface AccountDetailsResponse {
  success: boolean;
  data: {
    account: Account;
    users: AccountUser[];
    stats: AccountStats;
  };
}

export interface AccountsListResponse {
  success: boolean;
  data: Account[];
}

export interface CreateAccountResponse {
  success: boolean;
  message?: string;
  data: {
    account?: Account;
    admin: AccountUser;
  };
}

const accountsService = {
  // Listar todas as accounts
  async getAccounts(): Promise<Account[]> {
    const response = await api.get('/admin/accounts');
    return response.data.data;
  },

  // Obter detalhes de uma account
  async getAccount(id: string): Promise<Account> {
    const response = await api.get(`/admin/accounts/${id}`);
    return response.data.data.account;
  },

  // Criar nova account
  async createAccount(data: CreateAccountData): Promise<CreateAccountResponse> {
    const response = await api.post('/admin/accounts', data);
    return response.data;
  },

  // Atualizar account
  async updateAccount(id: string, data: Partial<Account>): Promise<Account> {
    const response = await api.patch(`/admin/accounts/${id}`, { account: data });
    return response.data.data;
  },

  // Deletar account
  async deleteAccount(id: string): Promise<{ success: boolean }> {
    const response = await api.delete(`/admin/accounts/${id}`);
    return response.data;
  },

  // Listar usuários de uma account
  async getAccountUsers(id: string): Promise<AccountUser[]> {
    const response = await api.get(`/admin/accounts/${id}/users`);
    return response.data.data;
  },

  // Atribuir role a um usuário
  async assignUserRole(accountId: string, userId: string, roleKey: string): Promise<AccountUser> {
    const response = await api.post(`/admin/accounts/${accountId}/users/${userId}/assign_role`, {
      role_key: roleKey
    });
    return response.data.data;
  }
};

export default accountsService;
