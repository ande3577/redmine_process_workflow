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
    field = ProcessField.new(:process_step => @step, :custom_field => @custom_field)
    assert field.save

    assert_equal @step, field.process_step
    assert_equal @custom_field, field.custom_field
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
