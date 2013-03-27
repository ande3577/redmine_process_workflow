class ProcessAction < ActiveRecord::Base
  unloadable
  
  belongs_to :issue
  belongs_to :process_field
  
  validates_presence_of :issue, :process_field, :date
  
end
