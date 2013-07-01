require File.expand_path('../../test_helper', __FILE__)

class ProcessFieldTest < ActiveSupport::TestCase
  fixtures :trackers
  fixtures :issue_statuses
  fixtures :custom_fields
  fixtures :issues

  def setup
    @tracker = Tracker.first
    @issue = Issue.where(:tracker_id => @tracker.id).first
    @status = IssueStatus.first
    
    @step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'step')
    assert @step.save
    
    @custom_field = ProcessCustomField.new(:name => 'custom_field', :field_format => 'float', :process_step => @step)
    assert @custom_field.save
    
    @field = @custom_field.process_field
    @field.reload
  end
  
  # Replace this with your real tests.
  def test_create
    assert_equal @step, @field.process_step
    assert_equal @custom_field, @field.custom_field
    assert @field.find_action(@issue), "create action when creating new field"
  end
  
  def test_destroy_step
    id = @step.id
    @step.destroy
    assert ProcessField.where(:process_step_id => id).empty?    
  end
  
  def test_destroy_custom_field
    id = @custom_field.id
    @custom_field.destroy
    assert ProcessField.where(:custom_field_id => id).empty?   
  end
  
  def test_evaluate
    next_step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'next_step')
    assert next_step.save
    
    condition = ProcessCondition.new(:process_field => @field, :comparison_mode => 'eql?', :comparison_value => 'value', :step_if_true => next_step)
    assert condition.save
    
    assert_equal nil, @field.evaluate('another_value')
    assert_equal next_step, @field.evaluate('value')
  end
  
  def test_evaluate_step_if_false
    next_step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'next_step')
    assert next_step.save
    
    condition = ProcessCondition.new(:process_field => @field, :comparison_mode => 'eql?', :comparison_value => 'value', :step_if_false => next_step)
    assert condition.save
    
    assert_equal next_step, @field.evaluate('another_value')
    assert_equal nil, @field.evaluate('value')
  end
  
  def test_create_without_step
    field = ProcessField.new(:custom_field => @custom_field)
    assert !field.save
  end
  
  def test_create_without_custom_field
    field = ProcessField.new(:process_step => @step)
    assert !field.save
  end
  
  def test_find_action
    action = ProcessAction.where(:process_field_id => @field.id, :issue_id => @issue.id).first
    
    assert_equal action, @field.find_action(@issue)
  end
  
end
