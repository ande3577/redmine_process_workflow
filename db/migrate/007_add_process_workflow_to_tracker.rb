class AddProcessWorkflowToTracker < ActiveRecord::Migration
  def change
    add_column :trackers, :process_workflow, :boolean, :default => false 
  end
end