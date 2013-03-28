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
  
end
