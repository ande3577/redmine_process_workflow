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
    
    @field = ProcessField.new(:process_step => @step, :custom_field => @custom_field)
    assert @field.save
    
    @user = User.find(2)
    @issue = Issue.first
    assert @issue.save
    
    @date = Time.now
    
    @action = ProcessAction.new(:process_field => @field, :value => 'value', :date => @date, :user => @user, :issue => @issue)
  end
  
  
  def test_create
    assert @action.save
    
    assert_equal @field, @action.process_field
    assert_equal 'value', @action.value
    assert_equal @date, @action.date
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
  
  def test_create_without_date
    @action.date = nil
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
    
    assert_equal @status, @issue.status
  end
  
  def test_apply_action_no_change
    condition = ProcessCondition.new(:process_field => @field, :field_value => 'mismatched_value', :process_step => @step, :comparison_mode => 'eql?')
    assert condition.save
    
    @action.save
    assert @action.apply_action()
    
    assert_equal @status, @issue.status
  end
  
  def test_apply_action_change_status
    condition = ProcessCondition.new(:process_field => @field, :field_value => 'value', :process_step => @next_step, :comparison_mode => 'eql?')
    assert condition.save
    
    @action.save
    assert @action.apply_action()
    
    assert_equal @next_status, @issue.status
  end
end
