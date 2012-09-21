Privly::Application.routes.draw do
  
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  match "/zero_bin/:id" => "zero_bins#show", :as => :show_zero_bins, :via => [:get]
  match "/zero_bin" => "zero_bins#create", :via => [:post]
  match "/zero_bin/index.html" => "zero_bins#create", :via => [:post]
  
  match '/posts/destroy_all' => 'posts#destroy_all', :via => :delete

  resources :token_authentications, :only => [:create, :new]
  match "token_authentications" => "token_authentications#show", :as => :show_token_authentications, :via => [:get, :post]
  match 'token_authentications' => 'token_authentications#destroy', :as => :destroy_token_authentications, :via => [:delete]

  devise_for :users, :controllers => { :invitations => 'users/invitations' }

  devise_scope :user do
    post "users/invitations/send_invitation" => "users/invitations#send_invitation", :as => :user_send_invitations
    post "users/invitations/send_update" => "users/invitations#send_update", :as => :user_send_update
  end 

  root :to => "welcome#index"
  
  #account settings and delete account
  get "pages/account"
  
  #nearly static pages
  get "pages/roadmap"
  get "pages/privacy"
  get "pages/donate"
  get "pages/download"
  get "pages/about"
  get "pages/kickstarter"
  
  #legacy pages
  get "pages/faq" => redirect("http://www.privly.org/faq")
  get "pages/join" => redirect("http://www.privly.org/")
  get "pages/people" => redirect("http://www.privly.org/people")
  get "pages/license" => redirect("/pages/about")
  get "pages/terms" => redirect("/pages/privacy")
  get "pages/irc" => redirect("http://www.privly.org/content/irc")
  get "pages/bug" => redirect("http://www.privly.org/content/bug-report")
  get "pages/email" => redirect("https://groups.google.com/forum/?fromgroups#!forum/privly")
  
  match '/posts/get_csrf' => "posts#get_csrf", :as => :get_csrf_post, :via => [:get]
  resources :posts
  
  # posts#create_anonymous is deprecated
  match '/posts/posts_anonymous' => "posts#create_anonymous", :as => :create_anonymous_post, :via => [:post]
  resources :shares, :only => [:create, :destroy, :update]

  match '/' => 'welcome#index', :as => :welcome

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
