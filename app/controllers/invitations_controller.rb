class InvitationsController < ApplicationController
  
  load_and_authorize_resource
  
  # GET /invitations
  # GET /invitations.json
  def index
    @invitations = @invitations.page(params[:page]).order('created_at DESC')
    respond_to do |format|
      format.html {
        @sidebar = {:news => false}
        render
      } # index.html.erb
      format.json { render :json => @invitations }
    end
  end

  # GET /invitations/1
  # GET /invitations/1.json
  def show
    respond_to do |format|
      format.html {
        @sidebar = {:news => false}
        render
      }
      format.json { render :json => @invitations }
    end
  end

  # GET /invitations/new
  # GET /invitations/new.json
  def new
    @invitation = Invitation.new
    @sidebar = {:news => true}
    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @invitation }
    end
  end

  # POST /invitations
  # POST /invitations.json
  def create
    
    @invitation = Invitation.new(params[:invitation])

    respond_to do |format|
      if @invitation.save
        format.html { redirect_to welcome_path, :notice => 'Thanks for the interest! We will email you when the open beta starts' }
        format.json { render :json => @invitation, :status => :created, :location => @invitation }
      else
        format.html { render :action => "new" }
        format.json { render :json => @invitation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /invitations/1
  # DELETE /invitations/1.json
  def destroy
    @invitation.destroy
    respond_to do |format|
      format.html { redirect_to invitations_url }
      format.json { head :ok }
    end
  end
  
end
