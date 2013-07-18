class AddDefaultNextStepIdToStep < ActiveRecord::Migration
  def change
    add_column :process_steps, :default_next_step_id, :integer 
  end
end