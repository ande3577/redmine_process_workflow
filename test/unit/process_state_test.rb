require File.expand_path('../../test_helper', __FILE__)

class ProcessStateTest < ActiveSupport::TestCase
  fixtures :issues
  
  def setup
    @tracker = Tracker.first
    @status = IssueStatus.first
    @issue = Issue.first
    
    @step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker)
    assert @step.save
    
    @state = ProcessState.new(:issue => @issue, :process_step => @step)
  end

  def test_create
    assert @state.save
    
    assert_equal @issue, @state.issue
    assert_equal @step, @state.process_step
  end
  
  def test_create_without_issue
    @state.issue = nil
    assert !@state.save
  end
  
  def test_create_duplicate_issue
    assert @state.save
    
    step2 = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker)
    assert step2.save
    
    state2 = ProcessState.new(:issue => @issue, :process_step => step2)
    assert !state2.save
  end
  
  def test_create_without_step
    @state.process_step = nil
    assert !@state.save
  end
end
