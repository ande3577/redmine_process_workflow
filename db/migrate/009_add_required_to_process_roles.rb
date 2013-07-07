class AddRequiredToProcessRoles < ActiveRecord::Migration
  def change
    add_column :process_roles, :is_required, :boolean, :default => false 
  end
end