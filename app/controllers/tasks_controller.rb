class TasksController < ApplicationController
  def index
    respond_to do |format|
      @tasks = Task.master_tasks.where(:user_id => current_user.id)
      format.json { render :json => @tasks }
      format.js
      format.html 
    end
  end
  
  def new
    @task = Task.new
    @task.master_task_id = params["master_id"]
    respond_to do |format|
      format.js
    end
  end
  
  def create
    Task.transaction do
      @task = Task.new(params[:task])
      @task.user_id = current_user.id
      @task.master_task_id = params[:master_task_id] if !params[:master_task_id].nil?
      @task.status = "event created"
      if @task.save
      puts @task.master_task_id.nil?
        redirect_to :action => "index" if @task.master_task_id.nil?
	redirect_to task_path(@task.master_task) if !@task.master_task_id.nil?
      else
        render :action => "new"
      end
    end
  end
  
  def show
    @task = Task.where(:id => params[:id]).first
  end
  
  def edit
    @task = Task.where(:id => params[:id]).first
  end

  def update
    Task.transaction do
      @task = Task.where(:id => params[:id]).first
      if @task.update_attributes!(params[:task])
        redirect_to :action => "index" if @task.master_task_id.nil?
	redirect_to task_path(@task.master_task) if !@task.master_task_id.nil?
      else
        render :action => "edit"
      end
    end
  end
  
  def destroy
    Task.transaction do
      task = Task.where(:id => params[:id]).first
      task.destroy
    end
  end

  def sub_tasks
    @master_task = Task.where(:id => params[:task_id]).first
    @sub_tasks = @master_task.sub_task
    respond_to do |format|
      format.json {render :json => @sub_tasks}
      format.js
    end
  end
end
