require File.expand_path('../../test_helper', __FILE__)

class ProcessMemberTest < ActiveSupport::TestCase
  fixtures :users
  fixtures :trackers
  
  def setup
    @user = User.first
    @process_role = ProcessRole.new(:tracker => Tracker.first, :name => 'role_name')
  end
  
  def test_create
    member = ProcessMember.new(:process_role => @process_role, :user => @user)
    assert member.save
    
    assert_equal @process_role, member.process_role
    assert_equal @user, member.user
  end
  
  def test_create_without_process_role
    member = ProcessMember.new(:user => @user)
    assert !member.save
  end
  
  def test_create_without_user
    member = ProcessMember.new(:process_role => @process_role)
    assert !member.save
  end
end
