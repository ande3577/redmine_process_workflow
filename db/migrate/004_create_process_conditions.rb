class CreateProcessConditions < ActiveRecord::Migration
  def change
    create_table :process_conditions do |t|
      t.integer :process_field_id
      t.string :field_value
      t.integer :step_if_true_id
      t.integer :step_if_false_id
      t.string :comparison_mode
    end
  end
end
