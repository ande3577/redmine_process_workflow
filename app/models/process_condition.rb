class ProcessCondition < ActiveRecord::Base
  unloadable
  
  belongs_to :process_field
  
  validates_presence_of :next_step
  validates_presence_of :process_field, :field_value
  
  def next_step
    ProcessStep.where(:id => :next_step_id).first
  end
  
end
