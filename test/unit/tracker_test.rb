require File.expand_path('../../test_helper', __FILE__)

class TrackerTest < ActiveSupport::TestCase
  fixtures :trackers
  fixtures :issue_statuses
  
  def setup
    @tracker = Tracker.first
    @status = IssueStatus.first
  end

  def test_process_steps_empty
    assert @tracker.process_steps.empty?
  end
  
  def test_process_steps
    step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker)
    assert step.save
    
    assert_equal 1, @tracker.process_steps.count
    assert_equal step, @tracker.process_steps.first
  end
  
  def test_is_not_process_workflow
    assert !@tracker.process_workflow?
  end
  
  def test_is_process_workflow
    @tracker.process_workflow = true
    @tracker.save
    @tracker.reload
    
    assert @tracker.process_workflow?
  end
  
  def test_steps_order
    step1 = ProcessStep.new(:name => 'step1', :issue_status => @status, :tracker => @tracker)
    assert step1.save
    
    step2 = ProcessStep.new(:name => 'step2', :issue_status => @status, :tracker => @tracker)
    assert step2.save
    
    assert_equal step1, @tracker.process_steps.first
    
    assert_equal 1, step1.position
    assert_equal 2, step2.position
    
    step1.move_lower
    step2.move_higher
    
    assert_equal 2, step1.position
    assert_equal 1, step2.position
    
    assert_equal step2, @tracker.process_steps.first
  end
  
end
