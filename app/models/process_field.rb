class NextStepValidator < ActiveModel::Validator
  def validate(record)
    if record.comparison_mode != 'none' && record.step_if_true.nil? && record.step_if_false.nil?
      record.errors[:base] << "Must specify at least one next step if comparison mode specified."
    end
  end
end

class ProcessField < ActiveRecord::Base
  unloadable
  
  belongs_to :process_step 
  belongs_to :custom_field
  
  belongs_to :step_if_true, :class_name => 'ProcessStep', :foreign_key => 'step_if_true_id'
  belongs_to :step_if_false, :class_name => 'ProcessStep', :foreign_key => 'step_if_false_id'
  validates_with NextStepValidator
  
  has_many :process_actions
  
  validates_presence_of :process_step, :custom_field
  validates :comparison_mode, :inclusion => { :in => %w(none eql? ne?) }
  
  def evaluate(value)
    case comparison_mode
    when 'none'
      return false
    when 'eql?'
      return value.eql?(field_value)
    when 'ne?'
      return !value.eql?(field_value)
    end
  end
  
end
