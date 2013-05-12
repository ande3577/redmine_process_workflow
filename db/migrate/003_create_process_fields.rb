class CreateProcessFields < ActiveRecord::Migration
  def change
    create_table :process_fields do |t|
      t.integer :process_step_id
      t.integer :custom_field_id
      t.string :comparison_mode
      t.string :field_value
      t.integer :step_if_true_id
      t.integer :step_if_false_id
    end
  end
end
