class NextStepValidator < ActiveModel::Validator
  def validate(record)
    if record.comparison_mode != 'none' && record.step_if_true.nil? && record.step_if_false.nil?
      record.errors[:base] << "Must specify at least one next step if comparison mode specified."
    end
  end
end

class ProcessField < ActiveRecord::Base
  unloadable
  
  include Redmine::SafeAttributes
  
  safe_attributes 'custom_field_id', 'comparison_mode', 'field_value', 'step_if_true_id', 'step_if_false_id'
  
  belongs_to :process_step 
  belongs_to :custom_field
  
  belongs_to :step_if_true, :class_name => 'ProcessStep', :foreign_key => 'step_if_true_id'
  belongs_to :step_if_false, :class_name => 'ProcessStep', :foreign_key => 'step_if_false_id'
  validates_with NextStepValidator
  
  has_many :process_actions, :dependent => :destroy
  
  validates_presence_of :process_step, :custom_field
  validates :comparison_mode, :inclusion => { :in => %w(none eql? ne?) }
    
  after_create do |field|
    Issue.where(:tracker_id => field.process_step.tracker.id).each do |issue|
      ProcessAction.create(:process_field => field, :issue => issue)
    end
  end
  
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
  
  def find_action(issue)
    ProcessAction.where(:issue_id => issue.id).first
  end
  
end
