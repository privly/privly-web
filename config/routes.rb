Privly::Application.routes.draw do
  
  # Active Admin
  devise_for :admin_users, ActiveAdmin::Devise.config
  
  # Endpoint for destroying all the user's stored posts
  match '/posts/destroy_all' => 'posts#destroy_all', :via => :delete
  
  # Authenticating Applications
  resources :token_authentications, :only => [:create, :new]
  match "token_authentications" => "token_authentications#show", :as => :show_token_authentications, :via => [:get, :post]
  match 'token_authentications' => 'token_authentications#destroy', :as => :destroy_token_authentications, :via => [:delete]
  
  # User authentication
  devise_for :users, :controllers => { :invitations => 'users/invitations', :sessions => 'sessions' }
  
  # Invitations and mailers
  devise_scope :user do
    post "users/invitations/send_invitation" => "users/invitations#send_invitation", :as => :user_send_invitations
    post "users/invitations/send_update" => "users/invitations#send_update", :as => :user_send_update
    post "users/invitations/use_invite" => "users/invitations#use_invite", :as => :user_use_invite
  end 

  root :to => "welcome#index"
  
  #account settings and delete account
  get "pages/account"
  
  #nearly static pages
  get "pages/privacy"
  get "pages/terms" => redirect("pages/privacy") # One central info page
  get "pages/license" => redirect("pages/privacy") # One central info page
  
  #legacy pages
  get "pages/donate" => redirect("https://priv.ly/pages/donate")
  get "pages/download" => redirect("https://priv.ly/pages/download")
  get "pages/about" => redirect("https://priv.ly/pages/about")
  get "pages/people" => redirect("https://priv.ly/pages/about")
  get "pages/roadmap" => redirect("https://priv.ly/pages/about")
  get "pages/kickstarter" => redirect("https://priv.ly/pages/kickstarter")
  get "pages/faq" => redirect("http://www.privly.org/faq")
  get "pages/join" => redirect("http://www.privly.org/content/how-get-started")
  get "pages/irc" => redirect("http://www.privly.org/content/irc")
  get "pages/bug" => redirect("http://www.privly.org/content/bug-report")
  get "pages/email" => redirect("https://groups.google.com/forum/?fromgroups#!forum/privly")

  # Posting initialization endpoint
  match '/posts/user_account_data' => "posts#user_account_data", 
    :as => :get_user_account_data, :via => [:get]
    
  # PlainPost form
  match '/posts/plain_post', :to  => redirect('/apps/PlainPost/new.html'), 
    :as => :new_plain_post, :via => [:get]
  
  # Information on creating new posts is in the privly-applications
  # bundle.
  get "posts/new" => redirect("/apps/Help/new.html")
  
  # Post storage and viewing
  resources :posts
  
  # Shares
  resources :shares, :only => [:create, :destroy, :update]
  
  # Root Page
  match '/' => 'welcome#index', :as => :welcome
  
  # Active Admin
  ActiveAdmin.routes(self)
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
