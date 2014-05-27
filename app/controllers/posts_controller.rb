# Posts are the central storage endpoint for Privly content. They optionally
# store cleartext markdown content and serialized JSON of any schema. Currently
# two posting applications use the Post endpoint: ZeroBins push encrypted content
# to the serialized JSON storage, and Privly "posts" use the rendered Markdown
# storage.
class PostsController < ApplicationController
  
  require 'csv'
  
  # Force the user to authenticate using Devise
  before_filter :authenticate_user!, :except => [:show, :update, 
                                                 :destroy, :user_account_data]
  
  # Determines whether the user has access to the 
  # resource and assigns the @post variable
  before_filter :load_and_authorize_resource, :except => [:destroy_all, 
    :user_account_data, :index, :create]
  
  # Obscure whether the record exists when not found
  rescue_from ActiveRecord::RecordNotFound do |exception|
    obscure_existence
  end
  
  # == Get the Index
  # 
  # Get a list of all the user's posts. The user must be authenticated.
  # This listing should only be used by a privly-application so it is
  # data-only (JSON).
  #  
  # ==== Routing  
  #
  # +GET+: /posts
  # +GET+: /posts.:format
  #
  # ==== Cookies
  #
  # User must be authenticated via a session cookie
  #
  # ==== Formats  
  #  
  # * +html+ (deprecated)
  # * +json+ Example:
  #          [{"created_at":"2012-09-05T04:08:31Z",
  #            "burn_after_date":"2012-09-19T04:08:31Z",
  #            "public":false,"updated_at":"2012-09-05T04:08:31Z",
  #            "structured_content":{"salt":"ytyzBr2OkEc",
  #            "iv":"RSBeCnAklAbi0qvq/P8twA","ct":"23hqJJ7QKNkxpLVtfp9uEg"},
  #            "id":149,"user_id":2,"content":null,"random_token":"a53642b006"}]
  # * +jsonp+
  # * +csv+ Returns a comma separated value file. Headers:
  #      content,created_at,updated_at,public
  #
  # ==== Parameters  
  # 
  # * *format* - _string_ - Optional
  # ** Values: html, json
  # ** Default: html
  #
  def index
    
    @posts = current_user.posts.all
    
    respond_to do |format|
      format.html {
        redirect_to "/apps/Index/new.html"
      }
      format.json {
        render :json => @posts.to_json(:methods => :privly_URL) }
      format.csv {
        @filename = "posts_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        csv_data = CSV.generate do |csv|
          csv << ["content", "created_at", "updated_at", "public"]
          @posts.each do |post|
            csv << [post.content, post.created_at, post.updated_at, post.public]
          end
        end
        send_data csv_data, :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=#{@filename}"
      }
    end
  end
  
  # == Shows an individual post.
  #
  # This endpoint is data-only, meaning you should only use the
  # JSON format. Privly-applications integrate with this endpoint
  # using the JSON format.
  #  
  # === Routing  
  #
  # +GET+: /posts
  # +GET+: /posts/:id.:format
  #
  # === Formats  
  #  
  # * +html+ (deprecated) 
  # * +json+ Example:
  #          {"created_at":"2012-09-05T04:08:31Z",
  #            "burn_after_date":"2012-09-19T04:08:31Z",
  #            "public":false,"updated_at":"2012-09-05T04:08:31Z",
  #            "structured_content":{"salt":"ytyzBr2OkEc",
  #            "iv":"RSBeCnAklAbi0qvq/P8twA","ct":"23hqJJ7QKNkxpLVtfp9uEg"},
  #            "id":149,"user_id":2,"content":null,"random_token":"a53642b006",
  #            "permissions":
  #                {canshow: true, canupdate: false, candestroy: false, 
  #                canshare: false}
  #          }
  # * +jsonp+
  #
  # === Parameters  
  #
  # <b>random_token</b> - _string_ - Required
  # * Values: Any string of non-whitespace characters
  # * Default: None 
  # Either the user owns the post, or they must supply this parameter.
  # Without this parameter the user will not be able to access this endpoint.
  #
  # *format* - _string_ - Optional
  # * Values: html, json
  # * Default: html
  #
  # === Response Headers
  # * +X-Privly-Url+ The URL for this content which should be posted to other
  # websites.
  def show
    
    # Count the number of permissioned requests the post has.
    # Note that users could use this to indicate the number of times content
    # has been read. Do not expose this lightly.
    if not @post.user.nil?
      User.increment_counter(:permissioned_requests_served, @post.user.id)
    end
    
    @injectable_url = @post.privly_URL
    response.headers["X-Privly-Url"] = @injectable_url
    
    respond_to do |format|
      format.html {
        redirect_to @injectable_url # Deprecated
        return
      }
      format.json {
        render :json => get_json, :callback => params[:callback]
      }
    end
  end
  
  # == Create a post.
  #  
  # === Routing  
  #
  # Create a post
  # POST /posts
  # POST /posts.:format
  #
  # === Formats  
  #  
  # * +html+
  # * +json+
  # * +jsonp+
  #
  # === Parameters  
  #
  # <b>post [content]</b> - _string_ - Optional
  # * Values: Any Markdown formatted string. No images supported.
  # * Default: nil
  # The content is rendered on the website, or for injection into web pages.
  #
  # <b>post [structured_content]</b> - _JSON_ - Optional
  # * Values: Any JSON document
  # * Default: nil
  # Structured content is for the storage of serialized JSON in the database.
  #
  # <b>post [privly_application]</b> - string - Optional
  # * Values: Any of the currently supported Privly application identifiers can
  # be set here. Current examples include "PlainPost" and "ZeroBin", but no
  # validation is performed on the string. It is only used to generate URLs
  # into the static folder of the server.
  # * Default: nil
  #
  # <b>post [public]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: nil
  # A public post is viewable by any user.
  #
  # <b>post [random_token]</b> - _string_ - Optional
  # * Values: Any string
  # * Default: A random sequence of Base64 characters
  # The random token is used to permission requests to content
  # not owned by the requesting user. It ensures the user has access to the link,
  # and not didn't crawl the resource identifiers.
  #
  # <b>post [seconds_until_burn]</b> - _integer_ - Optional
  # * Values: 1 to 99999999
  # * Default: nil
  # The number of seconds until the post is destroyed.
  # If this parameter is specified, then the burn_after_date
  # is ignored.
  #
  # <b>post [burn_after_date(1i)]</b> - _integer_ - Required
  # * Values: 2012
  # * Default: 2012
  # The year in which the content will be destroyed
  #
  # <b>post [burn_after_date(2i)]</b> - _integer_ - Required
  # * Values: 1 to 12
  # * Default: current month
  # The month in which the content will be destroyed
  #
  # <b>post [burn_after_date(3i)]</b> - _integer_ - Required
  # * Values: 1 to 31
  # Default: Defaults to two days from now if the user
  # is not logged in, otherwise it defaults to 14 days from now
  # The day after which the content will be destroyed. The combined day, 
  # month, and year must be within the next 14 days for users with
  # posting permission, or 2 days for users without posting permission.
  #
  # === Response Headers
  # * +X-Privly-Url+ The URL for this content which should be posted to other
  # websites.
  def create
    
    unless current_user.can_post
      redirect_to welcome_page_path
    end
    
    @post = Post.new
    @post.user = current_user
    @post.privly_application = params[:post][:privly_application]

    # Posts default to Private
    if params[:post][:public]
      @post.public = params[:post][:public]
    else
      @post.public = false
    end

    set_burn_date
    
    # The random token will be required for users other than the owner
    # to access the content. The model will generate a token before saving
    # if it is not assigned here.
    @post.random_token = params[:post][:random_token]
    
    @post.update_attributes(params[:post])
    
    respond_to do |format|
      if @post.save
        response.headers["X-Privly-Url"] = @post.privly_URL
        format.any { render :json => get_json, 
          :status => :created, :location => @post }
      else
        format.any { render :json => @post.errors, 
          :status => :unprocessable_entity }
      end
    end
  end
  
  # == Update a post.
  #
  # Requires update permission. 
  #
  # === Routing  
  #
  # Create a post
  # PUT /posts/:id
  # PUT /posts/:id.:format
  #
  # === Formats  
  #  
  # * +html+
  # * +json+
  # * +jsonp+
  #
  # === Parameters  
  #
  # <b>id</b> - _integer_ - Required
  # * Values: 0 to 9999999
  # * Default: None 
  # The identifier of the post.
  #
  # <b>random_token</b> - _string_ - Required
  # * Values: Any string of non-whitespace characters
  # * Default: None 
  # Either the user owns the post, or they must supply this parameter.
  # Without this parameter the user will not be able to access this endpoint.
  #
  # <b>post [content]</b> - _string_ - Optional
  # * Values: Any Markdown formatted string. No images supported.
  # * Default: nil 
  # The content is rendered on the website, or for injection into web pages.
  #
  # <b>post [structured_content]</b> - _JSON_ - Optional
  # * Values: Any JSON document
  # * Default: nil
  # Structured content is for the storage of serialized JSON in the database.
  #
  # <b>post [public]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: nil
  # A public post is viewable by any user.
  #
  # <b>post [random_token]</b> - _string_ - Optional
  # * Values: Any string
  # * Default: A random sequence of Base64 characters
  # The random token is used to permission requests to content
  # not owned by the requesting user. It ensures the user has access to the link,
  # and not didn't crawl the resource identifiers.
  #
  # <b>post [seconds_until_burn]</b> - _integer_ - Optional
  # * Values: 1 to 99999999
  # * Default: nil
  # The number of seconds until the post is destroyed.
  # If this parameter is specified, then the burn_after_date
  # is ignored. Requires destroy permission.
  #
  # <b>post [burn_after_date(1i)]</b> - _integer_ - optional
  # * Values: 2012
  # * Default: 2012
  # The year in which the content will be destroyed
  # Requires destroy permission.
  #
  # <b>post [burn_after_date(2i)]</b> - _integer_ - optional
  # * Values: 1 to 12
  # * Default: current month
  # The month in which the content will be destroyed
  # Requires destroy permission.
  #
  # <b>post [burn_after_date(3i)]</b> - _integer_ - optional
  # * Values: 1 to 31
  # Default: Defaults to two days from now if the user
  # is not logged in, otherwise it defaults to 14 days from now
  # The day after which the content will be destroyed. The combined day, 
  # month, and year must be within the next 14 days for users with
  # posting permission, or 2 days for users without posting permission.
  #
  # === Response Headers
  # * +X-Privly-Url+ The URL for this content which should be posted to other
  # websites.
  def update
    
    unless current_user == @post.user
      return
    end
    
    unless params[:post][:public].nil?
      @post.public = params[:post][:public]
    end
    
    unless params[:post][:random_token].nil?
      @post.random_token = params[:post][:random_token]
    end
    
    set_burn_date
    
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.json { render :json => get_json, :callback => params[:callback] }
      else
        format.json { render :json => @post.errors,
          :status => :unprocessable_entity }
      end
    end
  end
  
  # == Destroy a post.
  #
  # Requires destroy permission, or content ownership.
  #
  # === Routing  
  #
  # Destroy a post
  # DELETE /posts/:id
  # DELETE /posts/:id.:format
  #
  # === Formats  
  #  
  # * +html+
  # * +json+
  # * +jsonp+
  #
  # === Parameters  
  #
  # <b>id</b> - _integer_ - Required
  # * Values: 0 to 9999999
  # * Default: None 
  # The identifier of the post.
  #
  # <b>random_token</b> - _string_ - Required
  # * Values: Any string of non-whitespace characters
  # * Default: None 
  # Either the user owns the post, or they must supply this parameter.
  # Without this parameter the user will not be able to access this endpoint.
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { 
        if user_signed_in? and current_user.can_post
          redirect_to posts_url
        else
          redirect_to root_url
        end
        }
      format.json { head :ok }
    end
  end
  
  # == Destroy all of the User's owned posts.
  #
  # Requires content ownership.
  #
  # === Routing  
  #
  # Destroy a post
  # DELETE /posts/destroy_all
  #
  # === Formats  
  #  
  # * +html+
  #
  # === Parameters  
  #
  # <b>No Parameters</b>
  def destroy_all
    posts = current_user.posts

    posts.each do |post|
      post.destroy
    end

    redirect_to posts_url, :notice => "Destroyed all Posts."
  end
  
  # == Get User Account Data
  #
  # Returns JSON with CSRF token, and information about the
  # user account's current permissions.
  # This should only be called by posting applications
  # before submitting forms. This endpoint is included to make it easier to
  # generate applications without rendering a template.
  #
  # Elements of the JSON include:  
  #
  # csrf: The CSRF if a token which is expected in all posts to the
  # content server. This is a counter measure for Cross Site Request
  # forgery.
  #
  # burntAfter: The maximum lifetime of posts for the current user
  #
  # canPost: Whether or not the user can create content
  #
  # signedIn: Boolean indicating whether the user us signed into the server
  #
  # === Routing  
  #
  # GET /posts/user_account_data
  #
  # === Formats  
  #  
  # * +json+
  # * +jsonp+
  #
  # === Parameters  
  #
  # <b>No Parameters</b>
  def user_account_data
    
    render :json => {
                      :csrf => form_authenticity_token,
                      :burntAfter => Time.now + 30.days, # Current recommended max life
                      :canPost => user_signed_in?,
                      :signedIn => user_signed_in?
                     }, 
                     :callback => params[:callback]
  end
  
  private
    
    # Load the post if the user has access to it
    def load_and_authorize_resource
      user = current_user
      user ||= User.new # guest user (not logged in)
      
      post = Post.find(params[:id])
      
      # If the post will be destroyed in the next cron job, tell the user
      # it is already gone.
      if not post.burn_after_date.nil? and post.burn_after_date < Time.now
        obscure_existence
        return
      end
      
      if post.user == current_user
        @post = post
        return
      end
      
      if post.public and post.random_token == params[:random_token]
        @post = post
        return
        # has access
      end
      
      obscure_existence
      
    end
    
    # This helper gives a JSON document containing only the 
    # attributes the requestor has access to
    def get_json
      
      if not @post.user.nil? and @post.user == current_user
        post_json = @post.as_json
      else
        post_json = @post.as_json(:except => [:user_id, :updated_at, 
           :created_at])
      end
      
      if not @post.content.nil?
        post_json.merge!(
        :rendered_markdown => @post.content.safe_markdown)
      end
      
      permissioned = (@post.user == current_user)
      injectable_url = @post.privly_URL
      post_json.merge!(
         "X-Privly-Url" => injectable_url, 
         :permissions => {
           :canshow => true, 
           :canupdate => permissioned, 
           :candestroy => permissioned,
           :canshare => permissioned
           }
          )
      post_json
    end
    
    # Converts rails 3-part date form object to a Ruby Date object
    def convert_date(hash, date_symbol_or_string)
      attribute = date_symbol_or_string.to_s
      return Date.new(hash[attribute + '(1i)'].to_i, hash[attribute + '(2i)'].to_i, hash[attribute + '(3i)'].to_i)   
    end
    
    # Set the burn date on the model.
    # The user must have destroy permissions.
    # The burn_after_date(1i) parameter has higher precedence than the
    # seconds_until_burn parameter.
    def set_burn_date
      
      unless @post.user == current_user
        return
      end
      
      if params[:post]["burn_after_date(1i)"]
        @post.burn_after_date = convert_date params[:post], "burn_after_date"
        return
      end
      
      if params[:post][:seconds_until_burn]
        seconds_until_burn = params[:post][:seconds_until_burn]
        if seconds_until_burn == "" or seconds_until_burn == "nil"
          @post.burn_after_date = nil
        else
          seconds_until_burn = params[:post][:seconds_until_burn].to_i
          @post.burn_after_date = Time.now + seconds_until_burn.seconds
        end
      end
      
    end
  
end
