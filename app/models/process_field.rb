class ProcessField < ActiveRecord::Base
  unloadable
  
  include Redmine::SafeAttributes
  
  safe_attributes 'custom_field_id', 'move_to'
  
  belongs_to :process_step 
  belongs_to :custom_field
  
  has_many :process_actions, :dependent => :destroy
  
  has_many :process_conditions, :dependent => :destroy, :order => 'position'
  
  validates_presence_of :process_step, :custom_field
  
  acts_as_list :scope => :process_step  

  after_create do |field|
    Issue.where(:tracker_id => field.process_step.tracker.id).each do |issue|
      ProcessAction.create(:process_field => field, :issue => issue)
    end
  end
  
  def evaluate(value)
    process_conditions.each do |c|
      if c.evaluate(value)
        return c.step_if_true if c.step_if_true
      else
        return c.step_if_false if c.step_if_false
      end
    end
    
    nil
  end
  
  def find_action(issue)
    ProcessAction.where(:issue_id => issue.id).first
  end
  
end
