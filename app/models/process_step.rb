class ProcessStep < ActiveRecord::Base
  unloadable
  
  belongs_to :tracker, :status
  has_many :process_fields, :process_conditions
  has_one :process_role
  
  validate_presence_of :tracker, :status, :name
end
