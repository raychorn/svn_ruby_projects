class ProjectsController < ApplicationController
  # GET /projects
  # GET /projects.xml
  def index
    @projects = current_user.projects

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
      format.amf  { render :amf => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    @project = current_user.projects.find(
      is_amf ? params[0] : params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
      format.amf  { render :amf => @project }
    end
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = current_user.projects.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  # POST /projects
  # POST /projects.xml
  def create
    if is_amf
      @project = params[0]
      @project.user_id = current_user.id
      @project.created_at = @project.updated_at = Time.now
    else
      @project = current_user.projects.build(params[:project])
    end

    respond_to do |format|
      if @project.save
        format.html do
          flash[:notice] = 'Project was successfully created.'
          redirect_to(@project)
        end
        format.xml  { render :xml => @project,
          :status => :created, :location => @project }
        format.amf  { render :amf => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @project.errors,
          :status => :unprocessable_entity }
        format.amf  { render :amf => @project.errors }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    @project = current_user.projects.find(
      is_amf ? params[0].id : params[:id])
    if is_amf
      @project.name = params[0].name
      @project.notes = params[0].notes
      @project.completed = params[0].completed
    else
      @project.attributes = params[:project]
    end
    @project.save_with_gtd_rules!

    respond_to do |format|
      format.html do
        flash[:notice] = 'Project was successfully updated.'
        redirect_to(@project)
      end
      format.xml  { render :xml => @project }
      format.amf  { render :amf => @project }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { render :action => "edit" }
      format.xml  { render :xml => @project.errors.to_xml_full }
      format.amf  { render :amf => @project.errors }
    end
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project = current_user.projects.find(
      is_amf ? params[0] : params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { render :xml => @project }
      format.amf  { render :amf => @project }
    end
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  private
    def prevent_access(e)
      logger.info "ProjectsController#prevent_access: #{e}"
      respond_to do |format|
        format.html { redirect_to(projects_url) }
        format.xml  { render :text => "error" }
        format.amf  { render :amf  => "error" }
      end
    end
end
