require File.expand_path('../../test_helper', __FILE__)

class ProcessConditionTest < ActiveSupport::TestCase
  fixtures :trackers
  fixtures :issue_statuses
  fixtures :custom_fields
  fixtures :issues
  
  def setup
    @tracker = Tracker.first
    @issue = Issue.where(:tracker_id => @tracker.id).first
    @status = IssueStatus.first
    @custom_field = CustomField.first
    @step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'step')
    assert @step.save
    @field = ProcessField.new(:process_step => @step, :custom_field => @custom_field)
    assert @field.save
    
    @condition = ProcessCondition.new(:process_field => @field, :comparison_mode => 'eql?', :comparison_value => 'value', :step_if_true => @step)
  end

  def test_create
    assert @condition.save
    @condition.reload
    
    assert_equal @field, @condition.process_field
    assert_equal 'eql?', @condition.comparison_mode
    assert_equal 'value', @condition.comparison_value 
    assert_equal @step, @condition.step_if_true
  end
  
  def test_position
    assert @condition.save
    
    new_condition = ProcessCondition.new(:process_field => @field, :comparison_mode => 'eql?', :comparison_value => 'new_value', :step_if_true => @step)
    assert new_condition.save
    
    new_condition.move_to_top
    
    assert_equal new_condition, @field.process_conditions.first
  end
  
  def test_create_no_field
    @condition.process_field = nil
    assert !@condition.save
  end
  
  def test_create_no_comparison_mode
    @condition.comparison_mode = nil
    assert !@condition.save
  end
  
  def test_create_invalid_comparison_mode
    @condition.comparison_mode = 'invalid'
    assert !@condition.save
  end
  
  def test_create_ne
    @condition.comparison_mode = 'ne?'
    assert @condition.save
    @condition.reload
    
    assert_equal 'ne?', @condition.comparison_mode
  end
  
  def test_create_no_comparison_value
    @condition.comparison_value = nil
    assert !@condition.save
  end
  
  def test_create_step_if_false
    @condition.step_if_true = false
    @condition.step_if_false = @step
    assert @condition.save
    @condition.reload
    
    assert_equal @step, @condition.step_if_false
  end
  
  def test_create_no_step
    @condition.step_if_true = nil
    assert !@condition.save
  end
  
  def test_destroy_field
    assert @condition.save
    id = @field.id
    @field.destroy
    
    assert ProcessCondition.where(:process_field_id => id).empty?
  end
  
  def test_destroy_step_if_true
    next_step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'next_step')
    assert next_step.save
    
    @condition.step_if_true = next_step
    assert @condition.save
    
    next_step.destroy
    @condition.reload    
    assert @condition.step_if_true.nil?
  end
  
  def test_destroy_step_if_false
    next_step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'next_step')
    assert next_step.save
    
    @condition.step_if_false = next_step
    assert @condition.save
    @condition.reload
    
    next_step.destroy
    @condition.reload
    assert @condition.step_if_false.nil?
  end

  
  def test_evaluate_eql_true
    assert @condition.save
    
    assert @condition.evaluate('value')
  end
  
  def test_evaluate_eql_false
    assert @condition.save
    
    assert !@condition.evaluate('anotherValue')
  end
  
  def test_evaluate_ne_true
    @condition.comparison_mode = 'ne?'
    assert @condition.save
    
    assert @condition.evaluate('anotherValue')
  end
  
  def test_evaluate_ne_false
    @condition.comparison_mode = 'ne?'
    assert @condition.save
    
    assert !@condition.evaluate('value')   
  end
  
end
