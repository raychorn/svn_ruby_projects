class TasksController < ApplicationController
  # GET /tasks
  # GET /tasks.xml
  def index
    @tasks = current_user.tasks

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tasks }
      format.amf  { render :amf => @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.xml
  def show
    @task = current_user.tasks.find(
      is_amf ? params[0] : params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @task }
      format.amf  { render :amf => @task }
    end
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    @task = current_user.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  # POST /tasks
  # POST /tasks.xml
  def create
    if is_amf
      @task = params[0]
      @task.user_id = current_user.id
      @task.created_at = @task.updated_at = Time.now
    else
      @task = current_user.tasks.build(params[:task])
    end
    respond_to do |format|
      if @task.save
        format.html do
          flash[:notice] = 'Task was successfully created.'
          redirect_to(@task)
        end
        format.xml  { render :xml => @task, :status => :created,
          :location => @task }
        format.amf  { render :amf => @task }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @task.errors,
          :status => :unprocessable_entity }
        format.amf  { render :amf => @task.errors }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    @task = current_user.tasks.find(
      is_amf ? params[0].id : params[:id])
    if is_amf
      @task.name = params[0].name
      @task.notes = params[0].notes
      @task.project_id = params[0].project_id
      @task.location_id = params[0].location_id
      @task.next_action = params[0].next_action
      @task.completed = params[0].completed
    else
      @task.attributes = params[:task]
    end
    @task.save_with_gtd_rules!

    respond_to do |format|
      format.html do
        flash[:notice] = 'Task was successfully updated.'
        redirect_to(@task)
      end
      format.xml  { render :xml => @task }
      format.amf  { render :amf => @task }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { render :action => "edit" }
      format.xml  { render :xml => @task.errors.to_xml_full }
      format.amf  { render :amf => @task.errors }
    end
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = current_user.tasks.find(
      is_amf ? params[0] : params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(tasks_url) }
      format.xml  { render :xml => @task }
      format.amf  { render :amf => @task }
    end
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  private
    def prevent_access(e)
      logger.info "TasksController#prevent_access: #{e}"
      respond_to do |format|
        format.html { redirect_to(tasks_url) }
        format.xml  { render :text => "error" }
        format.amf  { render :amf  => "error" }
      end
    end
end
