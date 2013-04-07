class ProcessState < ActiveRecord::Base
  unloadable
  
  belongs_to :issue
  belongs_to :process_step
  
  validates_presence_of :issue
  validates_uniqueness_of :issue_id
  
  validates_presence_of :process_step
end
