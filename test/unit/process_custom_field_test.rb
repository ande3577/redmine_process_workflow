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
    
  end
  
  # Replace this with your real tests.
  def test_create
    assert  @custom_field.save
    assert_equal 1, ProcessCustomField.count
    assert_equal @step, @custom_field.process_step
    
    custom_field = ProcessCustomField.last
    assert_equal @step, custom_field.process_step
    
    assert_equal ProcessField.last, @custom_field.process_field
    assert_equal custom_field, ProcessField.last.custom_field
  end

  def test_create_without_step
    custom_field = ProcessCustomField.new(:name => 'custom_field', :field_format => 'float')
    assert !custom_field.save
  end
  
  def test_create_no_name
    custom_field = ProcessCustomField.new(:field_format => 'float', :process_step => @step)
    assert !custom_field.save, "make sure base validators are still running"
  end
  
  def test_destroy_process_field
    assert  @custom_field.save
    
    process_field = ProcessField.new(:process_step => @step, :custom_field => @custom_field)
    assert process_field.save
    
    id = process_field.id
    process_field.destroy
    
    assert_equal 0, ProcessCustomField.count
    
  end
  
  def test_create_duplicate
    assert  @custom_field.save
    @custom_field.reload
    
    new_custom_field = ProcessCustomField.new(:process_step => @step, :name => 'custom_field', :field_format => 'float')
    assert !new_custom_field.save
  end
  
  def test_create_duplicate_different_step
    assert  @custom_field.save
    @custom_field.reload
    
    new_step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'step')
    assert new_step.save
    
    new_custom_field = ProcessCustomField.new(:process_step => new_step, :name => 'custom_field', :field_format => 'float')
    assert new_custom_field.save
  end
  
end
