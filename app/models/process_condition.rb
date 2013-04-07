class NextStepValidator < ActiveModel::Validator
  def validate(record)
    if record.step_if_true.nil? && record.step_if_false.nil?
      record.errors[:base] << "Must specify at least one next step."
    end
  end
end

class ProcessCondition < ActiveRecord::Base
  unloadable
  
  belongs_to :process_field
  
  belongs_to :step_if_true, :class_name => 'ProcessStep', :foreign_key => 'id'
  belongs_to :step_if_false, :class_name => 'ProcessStep', :foreign_key => 'id'
  
  validates_with NextStepValidator
  validates_presence_of :process_field
  validates :comparison_mode, :inclusion => { :in => %w(eql? ne?) }

  def evaluate(value)
    case comparison_mode
    when 'eql?'
      return value.eql?(field_value)
    when 'ne?'
      return !value.eql?(field_value)
    end
  end
end

