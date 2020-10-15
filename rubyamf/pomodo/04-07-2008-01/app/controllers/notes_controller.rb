class NotesController < ApplicationController
  # GET /users/1/note
  # GET /users/1/note.xml
  def show
    if is_amf
      render :amf => current_user.note
    else
      if current_user.id != params[:user_id].to_i
        prevent_access
      else
        @note = current_user.note
        respond_to do |format|
          format.xml { render :xml => @note }
        end
      end
    end
  end

  # PUT /users/1/note
  # PUT /users/1/note.xml
  def update
    if is_amf
      @note = current_user.note
      @note.content = params[0].content
    else
      if current_user.id != params[:user_id].to_i
        prevent_access
      else
        @note = current_user.note
        @note.attributes = params[:note]
      end
    end
    @note.save!

    respond_to do |format|
      format.xml { render :xml => @note }
      format.amf { render :amf => @note }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.xml  { render :xml => @note.errors.to_xml_full }
      format.amf  { render :amf => @note.errors }
    end
  end
  
  private
    def prevent_access
      respond_to do |format|
        format.xml { render :text => "error" }
        format.amf { render :amf  => "error" }
      end
    end
end
