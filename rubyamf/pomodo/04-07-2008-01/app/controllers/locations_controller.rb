class LocationsController < ApplicationController
  # GET /locations
  # GET /locations.xml
  def index
    @locations = current_user.locations

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @locations }
      format.amf  { render :amf => @locations }
    end
  end

  # GET /locations/1
  # GET /locations/1.xml
  def show
    @location = current_user.locations.find(
      is_amf ? params[0] : params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @location }
      format.amf  { render :amf => @location }
    end
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  # GET /locations/new
  # GET /locations/new.xml
  def new
    @location = Location.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = current_user.locations.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  # POST /locations
  # POST /locations.xml
  def create
    if is_amf
      @location = params[0]
      @location.user_id = current_user.id
      @location.created_at = @location.updated_at = Time.now
    else
      @location = current_user.locations.build(
        params[:location])
    end

    respond_to do |format|
      if @location.save
        format.html do
          flash[:notice] = 'Location was successfully created.'
          redirect_to(@location)
        end
        format.xml  { render :xml => @location,
          :status => :created, :location => @location }
        format.amf  { render :amf => @location }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @location.errors,
          :status => :unprocessable_entity }
        format.amf  { render :amf => @location.errors }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.xml
  def update
    @location = current_user.locations.find(
      is_amf ? params[0].id : params[:id])
    if is_amf
      @project.name = params[0].name
      @project.notes = params[0].notes
      @project.completed = params[0].completed
    else
      @location.attributes = params[:location]
    end
    @location.save!

    respond_to do |format|
      format.html do
        flash[:notice] = 'Location was successfully updated.'
        redirect_to(@location)
      end
      format.xml  { render :xml => @location }
      format.amf  { render :amf => @location }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { render :action => "edit" }
      format.xml  { render :xml => @location.errors.to_xml_full}
      format.amf  { render :amf => @project.errors }
    end
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  # DELETE /locations/1
  # DELETE /locations/1.xml
  def destroy
    @location = current_user.locations.find(
      is_amf ? params[0] : params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(locations_url) }
      format.xml  { render :xml => @location }
      format.amf  { render :amf => @location }
    end
  rescue ActiveRecord::RecordNotFound => e
    prevent_access(e)
  end

  private
    def prevent_access(e)
      logger.info "LocationsController#prevent_access: #{e}"
      respond_to do |format|
        format.html { redirect_to(locations_url) }
        format.xml  { render :text => "error" }
        format.amf  { render :amf  => "error" }
      end
    end
end
