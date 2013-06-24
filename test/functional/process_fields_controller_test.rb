require File.expand_path('../../test_helper', __FILE__)

class ProcessFieldsControllerTest < ActionController::TestCase
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
  
  def test_index
    get :index, :process_step_id => @step.id
    assert_response 200
    
    step = assigns(:step)
    assert step
    assert_equal @step, step
    
    fields = assigns(:fields)
    assert fields
    assert_equal 1, fields.size
    assert_equal @field, fields.first
  end
  
  def test_new
    get :new, :process_step_id => @step.id
    assert_response 200
    
    field = assigns(:field)
    assert field
    assert_equal @step, field.process_step
  end
  
  def test_edit
    get :edit, :id => @field.id
    assert_response 200
    
    field = assigns(:field)
    assert field
    assert_equal @field, field
    
    conditions = assigns(:conditions)
    assert conditions
    assert_equal @condition, conditions.first
  end
  
  def test_create
    new_custom_field = CustomField.find(2)
    assert_difference 'ProcessField.count' do
          post :create, :process_step_id => @step.id, :process_field => { :custom_field_id => new_custom_field.id }
    end
    assert_redirected_to :controller => :process_steps, :action => :edit, :id => @step.id
    
    new_field = ProcessField.last
    assert_equal @step, new_field.process_step
    assert_equal new_custom_field, new_field.custom_field
  end
  
  def test_create_invalid
    new_custom_field = CustomField.find(2)
    assert_difference 'ProcessField.count', 0 do
          post :create, :process_step_id => @step.id, :process_field => { :custom_field_id => 99 }
    end
    assert_response 200
    assert_template :new
  end
  
  def test_update
    new_custom_field = CustomField.find(2)
    new_step = ProcessStep.new(:tracker => @tracker, :issue_status => @status, :name => 'new step')
    assert new_step.save
    
    post :update, :id => @field.id, :process_field => { :custom_field_id => new_custom_field.id, :process_step_id => new_step.id }
    assert_redirected_to :controller => :process_steps, :action => :edit, :id => @step.id  
    
    @field.reload
    assert_equal new_custom_field, @field.custom_field
    assert_equal @step, @field.process_step
  end
  
  def test_update_invalid
    post :update, :id => @field.id, :process_field => { :custom_field_id => 99, :id => @step.id }
    assert_response 200
    assert_template :edit
  end
  
  def test_destroy
    assert_difference 'ProcessField.count', -1 do
      delete :destroy, :id => @field.id
    end
    assert_redirected_to :controller => :process_steps, :action => :edit, :id => @step.id
  end
end
