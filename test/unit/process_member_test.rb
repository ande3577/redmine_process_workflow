require File.expand_path('../../test_helper', __FILE__)

class ProcessMemberTest < ActiveSupport::TestCase
  fixtures :users
  fixtures :trackers
  fixtures :issues
  
  def setup
    @user = User.first
    @issue = Issue.first
    @process_role = ProcessRole.new(:tracker => Tracker.first, :name => 'role_name')
  end
  
  def test_create
    member = ProcessMember.new(:process_role => @process_role, :user => @user, :issue => @issue)
    assert member.save
    
    assert_equal @process_role, member.process_role
    assert_equal @user, member.user
    assert_equal @issue, member.issue
  end
  
  def test_create_without_process_role
    member = ProcessMember.new(:user => @user, :issue => @issue)
    assert !member.save
  end
  
  def test_create_without_user
    member = ProcessMember.new(:process_role => @process_role, :issue => @issue)
    assert !member.save
  end
  
  def test_create_without_issue
    member = ProcessMember.new(:process_role => @process_role, :user => @user)
    assert !member.save
  end
end
