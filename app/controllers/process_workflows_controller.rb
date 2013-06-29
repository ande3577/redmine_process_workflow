class ProcessWorkflowsController < ApplicationController
  unloadable
  
  before_filter :require_admin
  before_filter :find_trackers
  before_filter :find_projects
  before_filter :find_tracker, :except => [ :index, :new, :create ]
  before_filter :build_tracker_from_params, :only => [:new, :create] 
  before_filter :find_steps, :only => [:edit, :update]
  before_filter :find_roles, :only => [:edit, :update]
    
  helper :process_steps
    
  def index
    respond_to do |format|
      format.html
    end
  end

  def new
  end
  
  def edit
    respond_to do |format|
      format.html
    end
  end

  def create
    if @tracker.save
      redirect_to :action => :edit, :id => @tracker.id
      return  
    end
    new
    render :action => :new
  end
  
  def update
    if @tracker.update_attributes(params[:tracker])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => :index
      return
    end
    render :action => 'edit'
  end
  
  def destroy
      unless @tracker.issues.empty?
        flash[:error] = l(:error_can_not_delete_tracker)
      else
        @tracker.destroy
      end
      redirect_to :controller => :process_workflows, :action => :index
  end
  
private  
  def find_trackers
    @trackers = []
      
    Tracker.sorted.each do |t|
      if t.process_workflow?
        @trackers << t
      end
    end
  end

  def find_tracker
    id = params[:id]
    if id.nil?
      render_404
      return false
    end

    @tracker = Tracker.where(:id => id).first
    if @tracker.nil? || !@tracker.process_workflow?
      render_404
      return false
    end
  end
  
  def find_projects
    @projects = Project.visible.active.all
  end
  
  def find_steps
    @steps = ProcessStep.where(:tracker_id => @tracker.id).order('position ASC').all
  end
  
  def find_roles
    @roles = @tracker.process_roles
  end
  
  def build_tracker_from_params
    @tracker = Tracker.new(params[:tracker])
    @tracker.process_workflow = true
  end
  
end
