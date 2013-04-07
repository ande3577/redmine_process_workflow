class ProcessAction < ActiveRecord::Base
  unloadable
  
  belongs_to :issue
  belongs_to :process_field
  has_one :user
  
  validates_presence_of :issue, :process_field, :timestamp, :user
  
  def apply_action
    condition = process_field.process_condition
    unless condition.nil?
      if condition.evaluate(value)
        unless condition.step_if_true.nil?
          issue.status = condition.step_if_true.issue_status
          return issue.save
        end
      elsif !condition.step_if_false.nil?
        issue.status = condition.step_if_false.issue_status
        return issue.save
      end
    end
    true
  end
  
end
