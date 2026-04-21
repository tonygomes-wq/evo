class AddTypeToContacts < ActiveRecord::Migration[7.1]
  def up
    # Criar tipo ENUM no PostgreSQL apenas se não existir
    execute <<-SQL
      DO $$ BEGIN
        CREATE TYPE contact_type_enum AS ENUM ('person', 'company');
      EXCEPTION
        WHEN duplicate_object THEN null;
      END $$;
    SQL
    
    # Adicionar coluna com ENUM apenas se não existir
    unless column_exists?(:contacts, :type)
      add_column :contacts, :type, :contact_type_enum, default: 'person', null: false
      add_index :contacts, :type
      
      # Atualizar contatos existentes para 'person'
      Contact.where(type: nil).update_all(type: 'person')
    end
  end

  def down
    if column_exists?(:contacts, :type)
      remove_index :contacts, :type if index_exists?(:contacts, :type)
      remove_column :contacts, :type
    end
    
    # Remover tipo ENUM do PostgreSQL
    execute <<-SQL
      DROP TYPE IF EXISTS contact_type_enum;
    SQL
  end
end
