class AddCompanyFieldsToContacts < ActiveRecord::Migration[7.1]
  def change
    # Add columns only if they don't exist
    unless column_exists?(:contacts, :tax_id)
      add_column :contacts, :tax_id, :string, limit: 14
    end
    
    unless column_exists?(:contacts, :website)
      add_column :contacts, :website, :string
    end
    
    unless column_exists?(:contacts, :industry)
      add_column :contacts, :industry, :string
    end
    
    # Add index only if it doesn't exist
    unless index_exists?(:contacts, [:tax_id], unique: true, where: "tax_id IS NOT NULL")
      add_index :contacts, [:tax_id], unique: true, where: "tax_id IS NOT NULL"
    end
  end
end
