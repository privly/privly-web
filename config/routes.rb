Privly::Application.routes.draw do

  root :to => "welcome#index"
  match '/' => 'welcome#index', :as => :welcome

  get "users/sign_in" => redirect("/apps/Login/new.html"), :as => :sign_in

  # Active Admin
  devise_for :admin_users, ActiveAdmin::Devise.config
  
  # Endpoint for destroying all the user's stored posts
  match '/posts/destroy_all' => 'posts#destroy_all', :via => :delete
  match '/user/destroy_account' => 'users#destroy', :via => :delete

  get "users/invitation/new" => redirect("/")

  # Authenticating Applications (used by mobile)
  resources :token_authentications, :only => [:create, :new]
  match "token_authentications" => "token_authentications#show", :as => :show_token_authentications, :via => [:get, :post]
  match 'token_authentications' => 'token_authentications#destroy', :as => :destroy_token_authentications, :via => [:delete]
  
  # User authentication
  devise_for :users, :controllers => { :invitations => 'users/invitations',
                                       :sessions => 'sessions',
                                       :confirmations => 'users/confirmations' }
  
  # Invitations and mailers
  devise_scope :user do
    post "users/invitations/send_invitation" => "users/invitations#send_invitation", :as => :user_send_invitations
    post "users/invitations/send_update" => "users/invitations#send_update", :as => :user_send_update
    post "users/invitations/use_invite" => "users/invitations#use_invite", :as => :user_use_invite
  end 

  #account settings and delete account
  get "pages/account"
  
  #nearly static pages
  get "pages/privacy"
  get "pages/terms" => redirect("/pages/privacy") # One central info page
  get "pages/license" => redirect("/pages/privacy") # One central info page
  
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
  
  # Post storage and viewing
  resources :posts
  
  # Active Admin
  ActiveAdmin.routes(self)
  
end
