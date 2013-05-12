require File.expand_path('../../test_helper', __FILE__)

class ProcessActionTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles,
           :groups_users,
           :trackers, :projects_trackers,
           :enabled_modules,
           :versions,
           :issue_statuses, :issue_categories, :issue_relations, :workflows,
           :enumerations,
           :issues, :journals, :journal_details,
           :custom_fields, :custom_fields_projects, :custom_fields_trackers, :custom_values,
           :time_entries
  
  def setup
    @status = IssueStatus.first
    @custom_field = CustomField.first
    @tracker = Tracker.first
    @next_status = IssueStatus.find(2)
    
    @step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker)
    assert @step.save
    
    @next_step = ProcessStep.new(:name => 'next_step', :issue_status => @next_status, :tracker => @tracker)
    assert @next_step.save
    
    @field = ProcessField.new(:process_step => @step, :custom_field => @custom_field, :comparison_mode => 'none')
    assert @field.save
    
    @user = User.find(2)
    @issue = Issue.first
    assert @issue.save
    
    @process_state = ProcessState.new(:issue => @issue, :process_step => @step)
    assert @process_state.save
    
    @timestamp = Time.now
    
    @action = ProcessAction.new(:process_field => @field, :value => 'value', :timestamp => @timestamp, :user => @user, :issue => @issue)
  end
  
  
  def test_create
    assert @action.save
    
    assert_equal @field, @action.process_field
    assert_equal 'value', @action.value
    assert_equal @timestamp, @action.timestamp
    assert_equal @user, @action.user
    assert_equal @issue, @action.issue
  end
  
  def test_create_without_process_field
    @action.process_field = nil
    assert !@action.save
  end
  
  def test_create_without_value
    @action.value = nil
    assert @action.save, "allow saving with null value"
    assert_equal nil, @action.value
  end
  
  def test_create_without_timestamp
    @action.timestamp = nil
    assert !@action.save
  end
  
  def test_create_without_user
    @action.user = nil
    assert !@action.save
  end
  
  def test_create_without_issue
    @action.issue = nil
    assert !@action.save
  end
  
  def test_apply_action_no_condition
    @action.save
    assert @action.apply_action()
    
    assert_equal @step, @issue.process_step
  end
  
  def test_apply_action_no_change
    @field.field_value = 'mismatched_value'
    @field.step_if_true = @step
    @field.comparison_mode = 'eql?'
    @field.save
    
    @action.save
    assert @action.apply_action()
    
    assert_equal @step, @issue.process_step
  end
  
  def test_apply_action_change_status
    @field.field_value = 'value'
    @field.step_if_true = @next_step
    @field.comparison_mode = 'eql?'
    @field.save
    
    @action.save
    assert @action.apply_action()
    
    assert_equal @next_step, @issue.process_step
  end
  
  def test_apply_no_change_false_condition
    @field.field_value = 'value'
    @field.step_if_false = @step
    @field.comparison_mode = 'ne?'
    @field.save
    
    @action.save
    assert @action.apply_action()
    assert_equal @step, @issue.process_step
  end
  
  def test_apply_action_change_status_false_condition
    @field.field_value = 'value'
    @field.step_if_false = @next_step
    @field.comparison_mode = 'ne?'
    @field.save
    
    @action.save
    assert @action.apply_action()
    
    assert_equal @next_step, @issue.process_step
  end
end
