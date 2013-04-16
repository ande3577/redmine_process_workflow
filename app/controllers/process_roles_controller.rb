class ProcessRolesController < ApplicationController
  unloadable
  
  before_filter :require_admin
  before_filter :find_tracker, :except => [:edit, :update, :destroy]
  before_filter :find_role, :only => [:edit, :update, :destroy]


  def index
    @roles = @tracker.process_roles
  end

  def new
    @role = ProcessRole.new(:tracker_id => @tracker.id)
  end

  def edit
  end

  def create
    @role = ProcessRole.new(params[:process_role])
    @role.tracker = @tracker
    if @role.save
      redirect_to :controller => :process_workflows, :action => :edit, :id => @tracker.id
      return
    end
    new
    render :action => :new
  end

  def update
    @role.update_attributes(params[:process_role])
    if @role.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => :process_workflows, :action => :edit, :id => @role.tracker.id
      return
    end
    edit
    render :action => :edit
  end

  def destroy
    tracker = @role.tracker
    @role.destroy
    redirect_to :controller => :process_workflows, :action => :edit, :id => tracker.id
  end
  
  private
  def find_tracker
    id = params[:process_workflow_id]
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
  
  def find_role
    id = params[:id]
    if id.nil?
      render_404
      return false
    end
    
    @role = ProcessRole.where(:id => id).first
    if @role.nil?
      render_404
      return false
    end
    
  end
end
