require File.expand_path('../../test_helper', __FILE__)

class ProcessFieldTest < ActiveSupport::TestCase
  fixtures :trackers
  fixtures :issue_statuses
  fixtures :custom_fields

  def setup
    @tracker = Tracker.first
    @status = IssueStatus.first
    @custom_field = CustomField.first
    @step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'step')
    assert @step.save
  end
  
  # Replace this with your real tests.
  def test_create
    field = ProcessField.new(:process_step => @step, :custom_field => @custom_field, :field_value => 'value', :step_if_true => @step, :comparison_mode => 'eql?')
    assert field.save
    field.reload

    assert_equal @step, field.process_step
    assert_equal @custom_field, field.custom_field
    assert_equal 'value', field.field_value
    assert_equal @step, field.step_if_true
    assert_equal 'eql?', field.comparison_mode
  end
  
  def test_create_without_field_value
    field = ProcessField.new(:process_step => @step, :custom_field => @custom_field, :step_if_true => @step, :comparison_mode => 'eql?')
    assert field.save, "allow creating with blank value"
  end
  
  def test_create_without_next_steps
    field = ProcessField.new(:process_step => @step, :custom_field => @custom_field, :field_value => 'value', :comparison_mode => 'eql?')
    assert !field.save
  end
  
  def test_create_without_next_steps_and_comparison_mode
    field = ProcessField.new(:process_step => @step, :custom_field => @custom_field, :field_value => 'value', :comparison_mode => 'none')
    assert field.save, "allow creating without next step if comparison mode none"
  end
  
  def test_create_with_next_step_if_false
    field = ProcessField.new(:process_step => @step, :custom_field => @custom_field, :field_value => 'value', :step_if_false => @step, :comparison_mode => 'eql?')
    assert field.save
    field.reload
    
    assert_equal @step, field.step_if_false
  end
  
  def test_comparison_mode
    field = ProcessField.new(:process_step => @step, :custom_field => @custom_field, :field_value => 'value', :step_if_true => @step)
    assert !field.save
    
    field.comparison_mode = 'invalid'
    assert !field.save
    
    field.comparison_mode = 'none'
    assert field.save
    
    field.comparison_mode = 'eql?'
    assert field.save
    
    field.comparison_mode = 'ne?'
    assert field.save
  end
  
  def test_evaluate_eql
    field = ProcessField.new(:process_step => @step, :custom_field => @custom_field, :field_value => 'value', :step_if_true => @step, :comparison_mode => 'eql?')
    assert field.save
    
    assert !field.evaluate('another_value')
    assert field.evaluate('value')
  end
  
  def test_evaluate_ne
    field = ProcessField.new(:process_step => @step, :custom_field => @custom_field, :field_value => 'value', :step_if_true => @step, :comparison_mode => 'ne?')
    assert field.save
    
    assert !field.evaluate('value')
    assert field.evaluate('!value')
  end
  
  def test_create_without_step
    field = ProcessField.new(:custom_field => @custom_field)
    assert !field.save
  end
  
  def test_create_without_custom_field
    field = ProcessField.new(:process_step => @step)
    assert !field.save
  end
end
