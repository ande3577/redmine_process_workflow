class ProcessStep < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  
  AUTHOR = -1
  
  safe_attributes 'process_role_id', 'issue_status_id', 'name', 'move_to'
  
  belongs_to :tracker
  acts_as_list :scope => :tracker
  
  belongs_to :issue_status
  has_many :process_fields, :dependent => :destroy
  has_many :process_states, :dependent => :destroy

  validates_presence_of :tracker, :issue_status
  validates :name, :length => { :minimum => 1 }
    
  after_save :update_issues_assigned_to
    
  def process_role
    ProcessRole.where(:id => self.process_role_id).first
  end
  
  def process_role=(r)
    if r.nil?
      self.process_role_id = r
    else
      self.process_role_id = r.id      
    end
  end
    
  def update_issues_assigned_to
    if process_role_id_changed?
      ProcessState.where(:process_step_id => self.id).each do |state|
        member = ProcessMember.where(:process_role_id => self.process_role_id, :issue_id => state.issue_id).first
        unless member.nil?
          state.issue.assigned_to = member.principal
          state.issue.save
        end
      end
    end
  end
  
  def role_is_author?
    if self.process_role_id == AUTHOR
      return true
    else
      return false
    end
  end
  
end
