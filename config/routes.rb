Privly::Application.routes.draw do
  
  match '/auth/:provider/callback' => 'authentications#create'
  match '/users/auth/:provider' => 'users/omniauth_callbacks#passthru'
  match '/posts/destroy_all' => 'posts#destroy_all', :method => :delete
  #resources :authentications

  resources :token_authentications, :only => [:create, :new]
  match "token_authentications" => "token_authentications#show", :as => :show_token_authentications, :via => [:get, :post]
  match 'token_authentications' => 'token_authentications#destroy', :as => :destroy_token_authentications, :via => [:delete]

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks", :invitations => 'users/invitations' }

  devise_scope :user do 
    get "users/invitations" => "users/invitations#index", :as => :user_invitations
    post "users/invitations" => "users/invitations#send_invitation", :as => :user_send_invitations
  end 

  root :to => "welcome#index"
  
  #account settings and delete account
  get "pages/account"
  
  #nearly static pages
  get "pages/faq"
  get "pages/join"
  get "pages/roadmap"
  get "pages/people"
  get "pages/license"
  get "pages/privacy"
  get "pages/terms" => redirect("/pages/privacy")
  get "pages/help"
  get "pages/irc"
  get "pages/bug"
  get "pages/donate"
  get "pages/download"
  get "pages/about"
  get "pages/email"
  get "pages/kickstarter" => redirect("http://www.kickstarter.com/projects/229630898/protect-your-content-anywhere-on-the-web-privly")
  
  

  resources :posts
  resources :email_shares, :only => [:create, :destroy, :update]

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
