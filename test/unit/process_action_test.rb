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
    @tracker.process_workflow = true
    assert @tracker.save
    
    @next_status = IssueStatus.find(2)
    
    @step = ProcessStep.new(:name => 'name', :issue_status => @status, :tracker => @tracker)
    assert @step.save
    
    @next_step = ProcessStep.new(:name => 'next_step', :issue_status => @next_status, :tracker => @tracker)
    assert @next_step.save
    
    @field = ProcessField.new(:process_step => @step, :custom_field => @custom_field)
    assert @field.save
    
    @user = User.find(2)
    assert @user.save
    
    @issue = Issue.first
    assert @issue.save
    
    @process_state = @issue.process_state
    assert @process_state
    
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
  
  def test_destroy_issue
    issue_id = @issue.id
    @issue.destroy
    assert ProcessAction.where(:issue_id => issue_id).empty?
  end
  
  def test_destroy_user
    assert @action.save
    
    assert_equal @user, @action.user
    @user.destroy
    @action.reload
    assert_equal User.anonymous, @action.user
  end
  
  def test_destroy_field
    assert @action.save
    
    id = @field.id
    @field.destroy
    assert ProcessAction.where(:process_field_id => id).empty?
  end
  
  def test_change_issue_tracker
    assert @action.save
    
    @issue.tracker = Tracker.last
    assert @issue.save
    assert ProcessAction.where(:issue_id => @issue.id).empty?
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
    assert @action.save, "allow not timestamp"
  end
  
  def test_create_without_user
    @action.user = nil
    assert @action.save, "allow saving with no user"
  end
  
  def test_create_without_issue
    @action.issue = nil
    assert !@action.save
  end
  
  def test_apply_action_change_step
    condition = ProcessCondition.new(:process_field => @field, :comparison_mode => 'eql?', :comparison_value => 'value', :step_if_true => @next_step)
    assert condition.save

    @action.save
    assert @action.apply_action()
    
    assert_equal @next_step, @issue.process_step
  end
  
  def test_custom_field
    assert_equal @custom_field, @action.custom_field
    assert_equal @custom_field.id, @action.custom_field_id
  end
  
  def test_custimized
    assert_equal false, @action.customized
  end
end
