class ProcessAction < ActiveRecord::Base
  unloadable
  
  include Redmine::SafeAttributes
  
  belongs_to :issue
  belongs_to :process_field
  has_one :user
  
  validates_presence_of :issue, :process_field
  
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
  
  def customized
    false
  end
  
  def custom_field
    process_field.custom_field
  end
  
  def custom_field_id
    custom_field.id
  end
  
  # Returns true if the boolean custom value is true
  def true?
    self.value == '1'
  end

  def editable?
    custom_field.editable?
  end

  def visible?
    custom_field.visible?
  end

  def required?
    custom_field.is_required?
  end

  def to_s
    value.to_s
  end
  
end
