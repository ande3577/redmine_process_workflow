class ProcessField < ActiveRecord::Base
  unloadable
  
  belongs_to :process_step 
  belongs_to :custom_field
  
  has_many :process_actions
  
  has_one :process_condition
  
  validates_presence_of :process_step, :custom_field
  
end
