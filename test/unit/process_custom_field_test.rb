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
    @custom_field = ProcessCustomField.new(:name => 'custom_field', :field_format => 'float')
    
    @step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'step')
    assert @step.save
  end
  
  # Replace this with your real tests.
  def test_create
    assert  @custom_field.save
    assert_equal 1, ProcessCustomField.count
  end
  
  def test_process_field
    assert  @custom_field.save
        
    process_field = ProcessField.new(:process_step => @step, :custom_field => @custom_field)
    assert process_field.save
    
    assert_equal process_field, @custom_field.process_field
  end
  
  def test_destroy_process_field
    assert  @custom_field.save
    
    process_field = ProcessField.new(:process_step => @step, :custom_field => @custom_field)
    assert process_field.save
    
    id = process_field.id
    process_field.destroy
    
    assert_equal 0, ProcessCustomField.count
    
  end
  
end
