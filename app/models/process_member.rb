class ProcessMember < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  
  include Redmine::SafeAttributes
  
  safe_attributes 'user_id'
  
  belongs_to :user
  belongs_to :process_role
  belongs_to :issue
  
  after_save :update_issue_assigned_to
  
  validates_presence_of :user, :process_role, :issue
  
  def update_issue_assigned_to
    if user_id_changed? && !issue.process_step.nil? && (issue.process_step.process_role == process_role)
      issue.assigned_to = user
      issue.save
    end
  end
  
end
