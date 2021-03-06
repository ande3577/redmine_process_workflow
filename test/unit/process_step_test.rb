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
  
  def test_position
    step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker)
    assert step.save
    
    new_step = ProcessStep.new(:name => 'new_step', :issue_status => @status, :tracker => @tracker)
    assert new_step.save
    
    new_step.move_to_top
    
    assert_equal new_step, @tracker.process_steps.first
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
  
  def test_role_is_author
    step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker, :process_role_id => ProcessStep::AUTHOR)
    assert step.save
    step.reload
            
    assert_equal true, step.role_is_author?
  end
  
  def test_default_next_step
    step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker)
    assert step.save
    step.reload
    
    assert_equal nil, step.default_next_step
    
    new_step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker, :default_next_step_id => step.id)
    assert new_step.save
    
    assert_equal step, new_step.default_next_step
    
    step.destroy
    new_step.reload
    assert_equal nil, new_step.default_next_step_id
  end
  
end
