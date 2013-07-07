class ProcessMember < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  
  include Redmine::SafeAttributes
  
  safe_attributes 'user_id'
  
  belongs_to :process_role
  belongs_to :issue
  
  after_save :update_issue_assigned_to
  belongs_to :principal, :foreign_key => 'user_id'
  
  validates_presence_of :process_role, :issue
  
  def update_issue_assigned_to
    if user_id_changed? && !issue.process_step.nil? && (issue.process_step.process_role == process_role)
      issue.assigned_to = principal
      issue.save
    end
  end
  
end
