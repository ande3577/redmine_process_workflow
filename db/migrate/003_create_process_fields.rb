class CreateProcessFields < ActiveRecord::Migration
  def change
    create_table :process_fields do |t|
      t.integer :process_step_id
      t.integer :custom_field_id
    end
  end
end
