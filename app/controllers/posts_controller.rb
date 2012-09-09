class PostsController < ApplicationController
  
  # Allow posting to the create_anonymous endpoint without the CSRF token
  skip_before_filter :verify_authenticity_token, :only => [:create_anonymous]
  
  # Force the user to authenticate using Devise
  before_filter :authenticate_user!, :only => [:destroy_all]
  
  # Checks request's permissions defined in ability.rb and loads 
  # resource if they have access. This will assign @post or @posts depending
  # on the action.
  load_and_authorize_resource :except => [:destroy_all, :create_anonymous, :get_csrf]
  
  # Obscure whether the record exists when not found
  rescue_from ActiveRecord::RecordNotFound do |exception|
    obscure_existence
  end
  
  # Obscure whether the record exists when denied access
  rescue_from CanCan::AccessDenied do |exception|
    
    # Count the number of requests the post has without being able to view it
    if not @post.nil? and not @post.user.nil?
      User.increment_counter(:nonpermissioned_requests_served, @post.user.id)
    end
    
    obscure_existence
  end
  
  # == Get the Index
  # 
  # Get a list of all the user's posts. The user must be authenticated.
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
  # * +html+
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
  # ** Values: html, json, iframe
  # ** Default: html
  #
  def index
    unless params[:format] == "csv"
      @posts = @posts.order('created_at DESC').page params[:page]
    end
    respond_to do |format|
      format.html {
        @sidebar = {:posts => true}
        render  # index.html.erb
      }
      format.json { render :json => @posts.to_json() }
      format.csv do |csv|
        @filename = "posts_" + Time.now.strftime("%m-%d-%Y") + ".csv"
        csv_data = FasterCSV.generate("") do |csv|
          csv << ["content", "created_at", "updated_at", "public"]
          @posts.each do |post|
            csv << [post.content, post.created_at, post.updated_at, post.public]
          end
        end
        send_data csv_data, :type => 'text/csv; charset=iso-8859-1; header=present',
          :disposition => "attachment; filename=#{@filename}"
      end
    end
  end
  
  # == Shows an individual post.
  #  
  # === Routing  
  #
  # +GET+: /posts
  # +GET+: /posts/:id.:format
  #
  # === Formats  
  #  
  # * +html+
  # * +json+ Example:
  #          {"created_at":"2012-09-05T04:08:31Z",
  #            "burn_after_date":"2012-09-19T04:08:31Z",
  #            "public":false,"updated_at":"2012-09-05T04:08:31Z",
  #            "structured_content":{"salt":"ytyzBr2OkEc",
  #            "iv":"RSBeCnAklAbi0qvq/P8twA","ct":"23hqJJ7QKNkxpLVtfp9uEg"},
  #            "id":149,"user_id":2,"content":null,"random_token":"a53642b006"}
  # * +jsonp+
  # * +iframe+  Intended for injectable applications.
  #
  # === Parameters  
  #
  # <b>random_token</b> - _string_ - Required
  # * Values: Any string of non-whitespace characters
  # * Default: None 
  # Either the user owns the post, or they must supply this parameter.
  # Without this parameter, even with complete share access to the content,
  # the user will not be able to access this endpoint.
  #
  # *format* - _string_ - Optional
  # * Values: html, json, iframe
  # * Default: html
  #
  # === Response Headers
  # * +X-Privly-Url+ The URL for this content which should be posted to other
  # websites.
  # * (deprecated) +privlyurl+
  def show
    
    # If the post will be destroyed in the next cron job, tell the user
    # it is already gone.
    if not @post.burn_after_date.nil? and @post.burn_after_date < Time.now
      raise ActiveRecord::RecordNotFound
    end
    
    # Count the number of permissioned requests the post has.
    # Note that users could use this to indicate the number of times content
    # has been read. Do not expose this lightly.
    if not @post.user.nil?
      User.increment_counter(:permissioned_requests_served, @post.user.id)
    end
    
    @injectable_url = get_injectable_url
    response.headers["X-Privly-Url"] = @injectable_url
    #deprecated
    response.headers["privlyurl"] = @injectable_url
    
    @share = Share.new
    
    respond_to do |format|
      format.html {
        @sidebar = {:post => true, :posts => true, :link_options => true}
        render
      }
      format.iframe { render }
      format.json {
        render :json => get_json, :callback => params[:callback]
      }
    end
  end
  
  # == Present an HTML form for creating a new post.
  #
  # Requires update permission.
  #
  # === Routing  
  #
  # GET /posts/new
  #
  # === Formats  
  #  
  # * +html+
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
  # <b>post [public]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: true
  # Indicates whether anyone can view the content.
  #
  def new
    @sidebar = {:markdown => true, :posts => true}
    
    if user_signed_in? and current_user.can_post
      @post.burn_after_date = Time.now + 14.days
    else
      @post.burn_after_date = Time.now + 1.day
    end
    
    
    if params[:post] and not params[:post][:public].nil?
      @post.public = params[:post][:public]
    end
    
    respond_to do |format|
      format.html # new.html.erb
    end
  end
  
  # == Edit a post.
  #
  # Requires update permission.
  #
  # === Routing  
  #
  # Create a post
  # POST /posts
  # POST /posts.html
  #
  # === Formats  
  #  
  # * +html+
  #
  # === Parameters  
  #
  # <b>random_token</b> - _string_ - Required
  # * Values: Any string of non-whitespace characters
  # * Default: None 
  # Either the user owns the post, or they must supply this parameter.
  # Without this parameter, even with complete share access to the content,
  # the user will not be able to access this endpoint.
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
  def edit
    @sidebar = {:markdown => true, :post => true, :posts => true}
    respond_to do |format|
      format.html {
        if @post.structured_content.nil?
          render # edit.html.erb
        else
          render "edit", :locals => 
            {:notice => "This post was generated with a web application. Changing this content might not change how the link is displayed."}
        end
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
  # <b>post [share [share_csv]]</b> - _csv_ - Optional
  # * Values: a single row of comma separated values
  # * Default: nil
  # Send in comma separated values representing identities
  # like domains, emails, and IP Addresses.
  #
  # <b>post [share [can_show]]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: true
  # Assign a show sharing permission to the share_csv row's values
  #
  # <b>post [share [can_update]]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: false
  # Assign a update sharing permission to the share_csv row's values
  #
  # <b>post [share [can_destroy]]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: false
  # Assign a destroy sharing permission to the share_csv row's values
  #
  # <b>post [share [can_share]]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: false
  # Assign a share sharing permission to the share_csv row's values
  #
  # === Response Headers
  # * +X-Privly-Url+ The URL for this content which should be posted to other
  # websites.
  # * (deprecated) +privlyurl+
  def create
    
    if user_signed_in? and current_user.can_post
      @post.user = current_user
      @post.burn_after_date = Time.now + 2.weeks
    else
      @post.user = nil
      @post.burn_after_date = Time.now + 1.day
    end
    
    # Posts default to Private
    if params[:post][:public]
      @post.public = params[:post][:public]
    else
      @post.public = false
    end
    
    # The random token will be required for users other than the owner
    # to access the content. The model will generate a token before saving
    # if it is not assigned here.
    @post.random_token = params[:post][:random_token]
    
    # Set the length of time until the post is destroyed
    # by the server.
    if params[:post][:seconds_until_burn]
      seconds_until_burn = params[:post][:seconds_until_burn].to_i
      @post.burn_after_date = Time.now + seconds_until_burn.seconds
    elsif params[:post]["burn_after_date(1i)"]
      @post.burn_after_date = convert_date params[:post], "burn_after_date"
    end
    
    respond_to do |format|
      if @post.save
        
        # Create a series of shares based on a CSV line. 
        # All shares will have the same permissions, 
        # defaulting to viewing permission only.
        if params[:post][:share] and params[:post][:share][:share_csv]
          @shares = @post.add_shares_from_csv params[:post][:share][:share_csv],
                                                    params[:post][:share][:can_show],
                                                    params[:post][:share][:can_update],
                                                    params[:post][:share][:can_destroy],
                                                    params[:post][:share][:can_share] 
        end
        
        injectable_url = get_injectable_url
        response.headers["X-Privly-Url"] = injectable_url
        response.headers["privlyurl"] = injectable_url #deprecated
        
        format.html { redirect_to injectable_url, :notice => 'Post was successfully created.' }
        format.json { render :json => get_json, :status => :created, :location => @post }
        format.any { render :json => get_json, :status => :created, :location => @post }
      else
        format.html { render :action => "new" }
        format.json { render :json => @post.errors, :status => :unprocessable_entity }
        format.any { render :json => @post.errors, :status => :unprocessable_entity }
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
  # Without this parameter, even with complete share access to the content,
  # the user will not be able to access this endpoint.
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
  # <b>post [share [share_csv]]</b> - _csv_ - Optional
  # * Values: a single row of comma separated values
  # * Default: nil
  # Send in comma separated values representing identities
  # like domains, emails, and IP Addresses.
  #
  # <b>post [share [can_show]]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: true
  # Assign a show sharing permission to the share_csv row's values
  #
  # <b>post [share [can_update]]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: false
  # Assign a update sharing permission to the share_csv row's values
  #
  # <b>post [share [can_destroy]]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: false
  # Assign a destroy sharing permission to the share_csv row's values
  #
  # <b>post [share [can_share]]</b> - _boolean_ - Optional
  # * Values: true, false
  # * Default: false
  # Assign a share sharing permission to the share_csv row's values
  #
  # === Response Headers
  # * +X-Privly-Url+ The URL for this content which should be posted to other
  # websites.
  # * (deprecated) +privlyurl+
  def update
    
    # Permissions can only be updated by people with sharing permission
    if can? :share, @post
      
      # Create a series of shares based on a CSV line. 
      # All shares will have the same permissions, 
      # defaulting to viewing permission only.
      if params[:post][:share] and params[:post][:share][:share_csv]
        @shares = @post.add_shares_from_csv params[:post][:share][:share_csv],
                                                  params[:post][:share][:can_show],
                                                  params[:post][:share][:can_update],
                                                  params[:post][:share][:can_destroy],
                                                  params[:post][:share][:can_share]
      end
      
      @post.public = params[:post][:public]
      if not params[:post][:random_token].nil?
        @post.random_token = params[:post][:random_token]
      end
    end
    
    # Attributes which may lead to the destruction of the content can only
    # be updated by people with destruction permissions
    if can? :destroy, @post
        if params[:post][:seconds_until_burn]
          seconds_until_burn = params[:post][:seconds_until_burn].to_i
          @post.burn_after_date = Time.now + seconds_until_burn.seconds
        elsif params[:post][:burn_after_date]
          @post.burn_after_date = params[:post][:burn_after_date]
        end
    end
    
    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to get_injectable_url, :notice => 'Post was successfully updated.' }
        format.json { render :json => get_json, :callback => params[:callback] }
      else
        format.html { render :action => "edit" }
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
  # Without this parameter, even with complete share access to the content,
  # the user will not be able to access this endpoint.
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
  
  # == deprecated
  # A Create endpoint which will not associate the post with any user account
  # POST /posts/anonymous
  # POST /posts/anonymous.json
  def create_anonymous
    
    @post = Post.new(params[:post])
    
    if params[:post][:seconds_until_burn]
      seconds_until_burn = params[:post][:seconds_until_burn].to_i
      @post.burn_after_date = Time.now + seconds_until_burn.seconds
    else
      @post.burn_after_date = Time.now + 1.day
    end
    
    if @post.burn_after_date.nil? or @post.burn_after_date > Time.now + 1.day
      @post.burn_after_date = Time.now + 1.day
    end
    
    # Anonymous posts must be public
    @post.public = true
    
    respond_to do |format|
      if @post.save
        
        injectable_url = get_injectable_url
        response.headers["X-Privly-Url"] = injectable_url
        response.headers["privlyurl"] = injectable_url #deprecated
        
        format.html { redirect_to url, :notice => 'Post was successfully created.' }
        format.json {
          render :json => get_json, :status => :created, 
            :location => injectable_url,
            :callback => params[:callback] }
      else
        format.html { render :action => "new" }
        format.json { render :json => @post.errors, 
          :status => :unprocessable_entity }
      end
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
  
  # == Get CSRF Token.
  #
  # Returns javascript with CSRF token
  # This should only be called by posting applications
  # before submitting forms.
  #
  # === Routing  
  #
  # GET /posts/get_csrf
  #
  # === Formats  
  #  
  # * +json+
  # * +jsonp+
  #
  # === Parameters  
  #
  # <b>No Parameters</b>
  def get_csrf
    render :json => {:csrf => form_authenticity_token},
      :callback => params[:callback]
  end
  
  private
    
    # This helper gives the URL intended for injection into the page
    def get_injectable_url
      url = post_url @post, @post.injectable_parameters
      url
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
      
      injectable_url = get_injectable_url
      post_json.merge!(
         :privlyurl => injectable_url, #Deprecated
         "X-Privly-Url" => injectable_url, :privlyInject1 => true)
      
      post_json
    end
    
    # Converts rails 3 part date form object to a single Date object
    def convert_date(hash, date_symbol_or_string)
      attribute = date_symbol_or_string.to_s
      return Date.new(hash[attribute + '(1i)'].to_i, hash[attribute + '(2i)'].to_i, hash[attribute + '(3i)'].to_i)   
    end
  
end
