class UsersController < ApplicationController
  skip_before_filter :login_required, :only => [ :new, :create ]

  # GET /users/new
  # GET /users/new.xml
  def new
    # render new.rhtml
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])
    @user.save!
    self.current_user = @user
    respond_to do |format|
      format.html do
        redirect_back_or_default('/')
        flash[:notice] = "Thanks for signing up!"
      end
      format.xml  { render :xml => @user.to_xml }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html { render :action => 'new' }
      format.xml do
        if !@user.errors.empty?
          render :xml => @user.errors.to_xml_full
        else
          render :text => "error"
        end
      end
    end
  end
  
  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    if current_user.id == params[:id].to_i &&
      current_user.destroy
      cookies.delete :auth_token
      reset_session
      render :text => "success"
    else
      render :text => "error"
    end
  end
end
