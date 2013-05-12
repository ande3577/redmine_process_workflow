class CreateProcessActions < ActiveRecord::Migration
  def change
    create_table :process_actions do |t|
      t.integer :process_field_id
      t.string :value
      t.datetime :timestamp
      t.integer :user_id
      t.integer :issue_id
    end
  end
end
