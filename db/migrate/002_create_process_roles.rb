class CreateProcessRoles < ActiveRecord::Migration
  def change
    create_table :process_roles do |t|
      t.integer :tracker_id
      t.string :name
    end
  end
end
