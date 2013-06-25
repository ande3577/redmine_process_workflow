class NextStepValidator < ActiveModel::Validator
  def validate(record)
    if record.comparison_mode != 'none' && record.step_if_true.nil? && record.step_if_false.nil?
      record.errors[:base] << "Must specify at least one next step if comparison mode specified."
    end
  end
end

class ProcessCondition < ActiveRecord::Base
  unloadable
  
  include Redmine::SafeAttributes
  
  safe_attributes 'process_field_id', 'comparison_mode', 'comparison_value', 'step_if_true_id', 'step_if_false_id', 'move_to'
    
  belongs_to :process_field
  validates_presence_of :process_field
  
  acts_as_list :scope => :process_field 
  
  belongs_to :step_if_true, :class_name => 'ProcessStep', :foreign_key => 'step_if_true_id'
  belongs_to :step_if_false, :class_name => 'ProcessStep', :foreign_key => 'step_if_false_id'
  validates_with NextStepValidator
  
  validates :comparison_mode, :inclusion => { :in => %w(eql? ne? regex) }
    
  validates :comparison_value, :presence => true
  
  def evaluate(value)
    case comparison_mode
    when 'none'
      return false
    when 'eql?'
      return value.eql?(comparison_value)
    when 'ne?'
      return !value.eql?(comparison_value)
    when 'regex'
      return !(value.match(comparison_value)).nil?
    end
  end
  
end
