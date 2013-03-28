require File.expand_path('../../test_helper', __FILE__)

class ProcessStepTest < ActiveSupport::TestCase
  fixtures :trackers
  fixtures :issue_statuses
  
  def setup
    @tracker = Tracker.first
    @status = IssueStatus.first
  end

  def test_create
    step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker)
    assert step.save
    
    assert_equal 'name', step.name
    assert_equal @status, step.issue_status
    assert_equal @tracker, step.tracker
  end
  
  def test_create_without_tracker
    step = ProcessStep.new(:name => 'name', :issue_status => @status)
    assert !step.save
  end
  
  def test_create_without_status
    step = ProcessStep.new(:name => 'name', :tracker => @tracker)
    assert !step.save
  end
  
  def test_create_without_name
    step = ProcessStep.new(:issue_status => @status, :tracker => @tracker)
    assert !step.save
  end
  
  def test_create_empty_name
    step = ProcessStep.new(:name => '', :issue_status => @status, :tracker => @tracker)
    assert !step.save
  end
  
  def test_process_role
    role = ProcessRole.new(:tracker => @tracker, :name => 'role_name')
    assert role.save
        
    step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker, :process_role => role)
    assert step.save
        
    assert_equal role, step.process_role
  end
end
