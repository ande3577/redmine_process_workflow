class CreateProcessStates < ActiveRecord::Migration
  def change
    create_table :process_states do |t|
      t.integer :issue_id
      t.integer :process_step_id
    end
  end
end
