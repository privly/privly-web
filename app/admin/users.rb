ActiveAdmin.register User do
  
  # How many records to show per page
  config.per_page = 30
  
  # Allows for mass assignment of additional attributes
  controller do
    with_role :admin
  end
  
  # List of filters displayed to the right of the table
  filter :email
  filter :sign_in_count
  filter :current_sign_in_at
  filter :last_sign_in_at
  filter :confirmed_at
  filter :confirmation_sent_at
  filter :failed_attempts
  filter :created_at
  filter :admin
  #filter :alpha_invites
  #filter :beta_invites
  #filter :forever_account_value
  filter :permissioned_requests_served
  filter :nonpermissioned_requests_served
  filter :can_post, :as => :select
  filter :wants_to_test, :as => :select
  filter :accepted_test_statement, :as => :select
  filter :notifications, :as => :select
  
  
  # Which columns are shown in the table
  index do
    selectable_column
    column :email
    column :sign_in_count
    column :last_sign_in_at
    column :failed_attempts
    column :created_at
    
    #column :alpha_invites
    #column :beta_invites
    #column :forever_account_value
    #column :permissioned_requests_served
    #column :nonpermissioned_requests_served
    
    column :can_post
    column :wants_to_test
    column :accepted_test_statement
    column :notifications
    
    column "Posts" do |user|
      user.posts.count
    end
    
    # Show, edit, delete
    default_actions
    
    column "Send Confirmation Link" do |user|
      link_to "Send Invitation", { :action => "send_invitation", :controller=>"users/invitations", :user => {:id => user.id} },
            :confirm => "Send Invitation: Are you sure?", :method => :post
    end
    
  end
  
  # Turn on and off the user's posting ability
  #
  # This is an action you can perform on groups of users.
  # batch_action essentially registers a controller method, 
  # which is called by an automatically generated link on the index view
  # https://github.com/gregbell/active_admin/blob/master/docs/9-batch-actions.md#support-for-other-index-types
  batch_action :toggle_posting, :confirm => "Are you sure you want to toggle their posting permission?" do |selection|
    User.find(selection).each do |user|
      user.can_post = (user.can_post ^ true)
      user.save
    end
    redirect_to collection_path, :alert => "Users Have Been Toggled"
  end
  
  # Sidebar area help
  sidebar :help do
    ul do
      li "The Administration interface is under active development"
    end
  end
  
  # Importing CSV form calls collection_action :import_csv
  sidebar :import_csv do
    form_tag(import_csv_admin_users_path, :multipart => true) do
      file_field_tag('csv') +
      submit_tag("Submit", :confirm => "Are you sure you want to modify the user database with a CSV?")
    end
  end
  
  # Updates user table with the number of invites and forever
  # accounts the user has.
  #
  # expects rows with:
  # email,alpha_invites,beta_invites,forever_account_value
  # import_csv_admin_users_path
  # adds controller and route
  collection_action :import_csv, :method => :post do
    
    total_imported = 0
    total_updated = 0
    
    FasterCSV.parse(params[:csv].tempfile).each do |row|
      email = row[0]
      alpha_invites = row[1]
      beta_invites = row[2]
      forever_account_value = row[3]
      is_tester = (row[4].to_i == 1)
      
      user = User.find_by_email(email)
      
      if user
        user.alpha_invites = alpha_invites
        user.beta_invites = beta_invites
        user.forever_account_value = forever_account_value
        user.wants_to_test = is_tester
        if not user.save
          raise "error, user in CSV would not update"
        end
        total_updated += 1
      else
        user = User.new
        user.email = email
        user.alpha_invites = alpha_invites
        user.beta_invites = beta_invites
        user.forever_account_value = forever_account_value
        user.can_post = false
        user.wants_to_test = is_tester
        user.accepted_test_statement = false
        user.password = SecureRandom.base64(12)
        if not user.save
          raise "error, new user in CSV would not save"
        end
        total_imported += 1
      end
    end
    
    redirect_to admin_users_path, :alert => "CSV Import Successfull, " + 
      "#{total_imported} imported, #{total_updated} updated"
  end
  
  ## Adds a button to the top of the page 
  # action_item :only => :index do
  #  link_to('This is an Action Item',root_path) 
  # end
  
end
