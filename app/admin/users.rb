ActiveAdmin.register User do
  
  config.per_page = 30
  
  filter :email
  filter :sign_in_count
  filter :current_sign_in_at
  filter :last_sign_in_at
  filter :current_sign_in_ip
  filter :last_sign_in_ip
  filter :confirmed_at
  filter :confirmation_sent_at
  filter :failed_attempts
  filter :created_at
  filter :admin
  
  index do
    selectable_column
    column :email
    column :sign_in_count
    column :last_sign_in_at
    column :failed_attempts
    column :created_at
    
    column "Posts" do |user|
      user.posts.count
    end
    
    # Show, edit, delete
    default_actions
    
    ## custom single record action for the index page
    #column "Single Resource Action" do |user|
    #      link_to "new action", root_url
    #end
    
  end
  
  ## This is an action you can perform on groups of users.
  ## batch_action essentially registers a controller method, 
  ## which is called by an automatically generated link on the index view
  ## https://github.com/gregbell/active_admin/blob/master/docs/9-batch-actions.md#support-for-other-index-types
  #batch_action :flag, :confirm => "Are you sure you want to flag this user?" do |selection|
  #  User.find(selection).each do |user|
  #    user.failed_attempts += 1
  #    user.save
  #  end
  #  redirect_to collection_path, :alert => "Users Have Been Flagged"
  #end
  
  sidebar :help do
    ul do
      li "The Administration interface is under active development"
    end
  end
  
  ## adds controller and route
  #collection_action :import_csv, :method => :post do
  ##  Do some CSV importing work here...
  #  redirect_to root
  #end
  
  ## Adds a button to the top of the page 
  # action_item :only => :index do
  #  link_to('This is an Action Item',root_path) 
  # end
  
end
