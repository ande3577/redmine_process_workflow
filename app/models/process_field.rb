class ProcessField < ActiveRecord::Base
  unloadable
  
  belongs_to :process_step, :custom_field
  has_many :process_actions
  
  validates_presence_of :process_step, :custom_field
  
end
