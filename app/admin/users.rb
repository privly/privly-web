ActiveAdmin.register User do
  
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
    column :email
    column :sign_in_count
    column :last_sign_in_at
    column :failed_attempts
    column :created_at
    default_actions
  end
  
end
