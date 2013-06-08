class ProcessStepsController < ApplicationController
  unloadable

  before_filter :require_admin
  before_filter :find_tracker, :except => [ :edit, :update, :destroy  ]
  before_filter :find_step, :only => [ :edit, :update, :destroy ] 

  def index
    @steps = ProcessStep.where(:tracker_id => @tracker.id).order('position ASC').all
  end

  def new
    @step = ProcessStep.new
  end

  def edit
    @fields = ProcessField.where(:process_step_id => @step.id).order('position ASC').all
  end

  def create
    @step = ProcessStep.new(params[:process_step])
    @step.tracker = @tracker
    if @step.save
      redirect_to :controller => :process_workflows, :action => :edit, :id => @tracker.id
      return
    end
    new
    render :action => :new
  end

  def update
    @step.safe_attributes = params[:process_step]
    if @step.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => :process_workflows, :action => :edit, :id => @step.tracker_id
      return
    end
    edit
    render :action => :edit
  end

  def destroy
    @tracker = @step.tracker
    @step.destroy
    redirect_to :controller => :process_workflows, :action => :edit, :id => @tracker.id
  end
  
  private
  def find_tracker
    id = params[:tracker_id]
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
  
  def find_step
    id = params[:id]
    if id.nil?
      render_404
      return false
    end
        
    @step = ProcessStep.where(:id => id).first
    if @step.nil?
      render_404
      return false
    end
    
    @tracker = @step.tracker
  end
  
  
end
