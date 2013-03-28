class CreateProcessMembers < ActiveRecord::Migration
  def change
    create_table :process_members do |t|
      t.integer :user_id
      t.integer :process_role_id
    end
  end
end
