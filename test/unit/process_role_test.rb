require File.expand_path('../../test_helper', __FILE__)

class ProcessRoleTest < ActiveSupport::TestCase
  fixtures :trackers
  fixtures :users
  fixtures :issues
  
  def setup
    @tracker = Tracker.first
    @user = User.first
  end
  
  # Replace this with your real tests.
  def test_create
    role = ProcessRole.new(:tracker => @tracker, :name => 'name')
    assert role.save
    
    assert_equal @tracker, role.tracker
    assert_equal 'name', role.name
    assert !role.is_required?
  end
  
  def test_destroy_trackerr
    tracker = Tracker.new(:name => 'new_tracker')
    assert tracker.save
    role = ProcessRole.new(:tracker => tracker, :name => 'name')
    assert role.save

    id = tracker.id
    tracker.destroy
    assert ProcessRole.where(:tracker_id => id).empty?    
  end
  
  def test_create_no_tracker
    role = ProcessRole.new(:name => 'name')
    assert !role.save
  end
  
  def test_create_no_name
    role = ProcessRole.new(:tracker => @tracker, :name => '')
    assert !role.save
  end
  
  def test_process_members
    role = ProcessRole.new(:tracker => @tracker, :name => 'name')
    assert role.save
    
    assert_equal 0, role.process_members.count
    
    member = ProcessMember.new(:process_role => role, :principal => @user, :issue => Issue.first)
    assert member.save
    
    assert_equal 1, role.process_members.count
    assert_equal member, role.process_members.first
  end
  
  def test_is_required
    role = ProcessRole.new(:tracker => @tracker, :name => 'name', :is_required => true)
    assert role.save
    
    assert role.is_required?
    role.is_required = false
    assert !role.is_required?
  end
end
