class CreateProcessConditions < ActiveRecord::Migration
  def change
    create_table :process_conditions do |t|
      t.integer :position
      t.integer :process_field_id
      t.string :comparison_mode
      t.string :comparison_value
      t.integer :step_if_true_id
      t.integer :step_if_false_id
    end
  end
end
