require File.expand_path('../../test_helper', __FILE__)

class ProcessConditionTest < ActiveSupport::TestCase
  fixtures :trackers
  fixtures :issue_statuses
  fixtures :custom_fields

  def setup
    @tracker = Tracker.first
    @status = IssueStatus.first
    @custom_field = CustomField.first
    
    @step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'step')
    assert @step.save
    
    @field = ProcessField.new(:process_step => @step, :custom_field => @custom_field)
    assert @field.save
  end
  
  def test_create
    condition = ProcessCondition.new(:process_field => @field, :field_value => 'value', :process_step => @step, :comparison_mode => 'eql?')
    assert condition.save
    
    assert_equal @field, condition.process_field
    assert_equal 'value', condition.field_value
    assert_equal @step, condition.process_step
    assert_equal 'eql?', condition.comparison_mode
  end
  
  def test_create_without_field
    condition = ProcessCondition.new(:field_value => 'value', :process_step => @step, :comparison_mode => 'eql?')
    assert !condition.save
  end
  
  def test_create_without_field_value
    condition = ProcessCondition.new(:process_field => @field, :process_step => @step, :comparison_mode => 'eql?')
    assert condition.save, "allow creating with blank value"
  end
  
  def test_create_without_step
    condition = ProcessCondition.new(:field_value => 'value', :process_step => @step, :comparison_mode => 'eql?')
    assert !condition.save
  end
  
  def test_comparison_mode
    condition = ProcessCondition.new(:process_field => @field, :field_value => 'value', :process_step => @step)
    assert !condition.save
    
    condition.comparison_mode = 'invalid'
    assert !condition.save
    
    condition.comparison_mode = 'eql?'
    assert condition.save
    
    condition.comparison_mode = 'lt?'
    assert condition.save
    
    condition.comparison_mode = 'gt?'
    assert condition.save
    
    condition.comparison_mode = 'ne?'
    assert condition.save
    
  end
  
end
