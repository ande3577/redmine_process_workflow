class ProcessAction < ActiveRecord::Base
  unloadable
  
  belongs_to :issue
  belongs_to :process_field
  has_one :user
  
  validates_presence_of :issue, :process_field, :timestamp, :user
  
  def apply_action
    if process_field.evaluate(value)
      unless process_field.step_if_true.nil?
        return issue.apply_process_step_change(process_field.step_if_true)
      end
    elsif !process_field.step_if_false.nil?
      return issue.apply_process_step_change(process_field.step_if_false)
    end
    true
  end
  
end
