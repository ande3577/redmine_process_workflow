class ProcessMember < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  
  include Redmine::SafeAttributes
  
  safe_attributes 'user_id'
  
  belongs_to :process_role
  belongs_to :issue
  
  belongs_to :principal, :foreign_key => 'user_id'
  
  validates_presence_of :process_role, :issue
  
end
