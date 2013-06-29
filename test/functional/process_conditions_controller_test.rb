require File.expand_path('../../test_helper', __FILE__)

class ProcessConditionsControllerTest < ActionController::TestCase
  fixtures :trackers
  fixtures :issue_statuses
  fixtures :users
  fixtures :custom_fields
  
  def setup
    @tracker = Tracker.first
    @status = IssueStatus.first
    @custom_field = CustomField.first
    
    @step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'step')
    assert @step.save
    @field = ProcessField.new(:process_step => @step, :custom_field => @custom_field)
    assert @field.save
    @condition = ProcessCondition.new(:process_field => @field, :comparison_mode => 'eql?', :comparison_value => 'value', :step_if_true => @step)
    assert @condition.save
    
    @admin = User.where(:admin => true).first
    @request.session[:user_id] = @admin.id
  end
  
  def test_new
    get :new, :process_field_id => @field.id, :process_condition => { :comparison_mode => 'eql?'}
    assert_response 200
    
    condition = assigns(:condition)
    assert condition
    assert_equal 'eql?', condition.comparison_mode
    assert_equal @field, condition.process_field
  end
  
  def test_edit
    get :edit, :id => @condition.id
    assert_response 200
    
    condition = assigns(:condition)
    assert condition
    assert_equal @condition, condition
  end
  
  def test_create
    assert_difference 'ProcessCondition.count' do
          post :create, :process_field_id => @field.id, :process_condition => { :comparison_mode => 'eql?', :comparison_value => 'value', :step_if_true_id => @step.id }
    end
    assert_redirected_to :controller => :process_fields, :action => :edit, :id => @field.id
    
    new_condition = ProcessCondition.last
    assert_equal @field, new_condition.process_field
  end
  
  def test_create_invalid
    assert_difference 'ProcessCondition.count', 0 do
          post :create, :process_field_id => @field.id, :process_condition => { :comparison_mode => 'invalid', :comparison_value => 'value', :step_if_true_id => @step.id }
    end
    assert_response 200
    assert_template :new
  end
  
  def test_update
    post :update, :id => @condition.id, :process_condition => { :comparison_mode => 'ne?', :comparison_value => 'new_value', :step_if_true_id => nil, :step_if_false_id => @step.id}
    assert_redirected_to :controller => :process_fields, :action =>:edit, :id => @field.id  
    
    @condition.reload
    assert_equal 'ne?', @condition.comparison_mode
    assert_equal 'new_value', @condition.comparison_value
    assert_equal nil, @condition.step_if_true
    assert_equal @step, @condition.step_if_false
  end
  
  def test_update_invalid
    post :update, :id => @condition.id, :process_condition => { :process_field_id => 99 }
    assert_response 200
    assert_template :edit
  end
  
  def test_destroy
    assert_difference 'ProcessCondition.count', -1 do
      delete :destroy, :id => @condition.id
    end
    assert_redirected_to :controller => :process_fields, :action => :edit, :id => @field.id
  end
end
