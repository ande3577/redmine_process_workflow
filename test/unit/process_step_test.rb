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
  
  def test_destroy_status
    new_status = IssueStatus.new(:name => 'new_status')
    step = ProcessStep.new(:name => 'name', :issue_status => new_status, :tracker => @tracker)
    assert step.save
    
    id = new_status.id
    new_status.destroy
    assert ProcessStep.where(:issue_status_id => id).empty?
  end
  
  def test_destroy_tracker
    new_tracker = Tracker.new(:name => 'new_tracker')
    assert new_tracker.save
    step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => new_tracker)
    assert step.save
    
    id = new_tracker.id
    new_tracker.destroy
    assert ProcessStep.where(:tracker_id => id).empty?
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
    step.reload
        
    assert_equal role, step.process_role
  end
end
