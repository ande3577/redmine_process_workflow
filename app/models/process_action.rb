class ProcessAction < ActiveRecord::Base
  unloadable
  
  include Redmine::SafeAttributes
  
  belongs_to :issue
  belongs_to :process_field
  belongs_to :user
  
  validates_presence_of :issue, :process_field
  
  def apply_action
    return issue.apply_process_step_change(process_field.evaluate(value))
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
