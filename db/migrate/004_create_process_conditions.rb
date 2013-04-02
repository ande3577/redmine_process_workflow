class CreateProcessConditions < ActiveRecord::Migration
  def change
    create_table :process_conditions do |t|
      t.integer :process_field_id
      t.string :field_value
      t.integer :process_step_id
      t.string :comparison_mode
    end
  end
end
