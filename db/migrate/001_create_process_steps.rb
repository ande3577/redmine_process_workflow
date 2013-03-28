class CreateProcessSteps < ActiveRecord::Migration
  def change
    create_table :process_steps do |t|
      t.integer :tracker_id
      t.integer :process_role_id
      t.integer :issue_status_id
      t.string :name
    end
  end
end
