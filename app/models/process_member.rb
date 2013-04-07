class ProcessMember < ActiveRecord::Base
  unloadable
  
  belongs_to :user
  belongs_to :process_role
  belongs_to :issue
  
  validates_presence_of :user, :process_role, :issue
  
end
