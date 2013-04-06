class ProcessAction < ActiveRecord::Base
  unloadable
  
  belongs_to :issue
  belongs_to :process_field
  has_one :user
  
  validates_presence_of :issue, :process_field, :date, :user
  
  def apply_action
    condition = process_field.process_condition
    unless condition.nil?
      if condition.evaluate(value)
        issue.status = condition.process_step.issue_status
        return issue.save
      end
    end
    true
  end
  
end
