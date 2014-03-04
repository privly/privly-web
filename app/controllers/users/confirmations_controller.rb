class Users::ConfirmationsController < Devise::ConfirmationsController

  # == Create a confirmation.
  #
  # When a user tries to resend confirmation instructions, it has 
  # to be checked if that user's account has been approved by the
  # administrator, otherwise it has to be redirected back.
  #
  # === Routing  
  #
  # POST /user/confirmation
  #
  # === Formats  
  #  
  # * +html+
  #
  # === Parameters  
  #
  # <b>user [email]</b> - _string_ - Required
  # * Values: valid email address
  # * Default: nil
  # The email of the user that wants confirmation instructions to be resent
  def create

    email = params[:user][:email]
    user = User.find_by_email(email)

    # Check if the user has previously signed up
    if not user
    	redirect_to new_user_session_path, :notice => "If your e-mail exists on our database, you will receive an email with instructions about how to confirm your account in a few minutes."

    # If the account is approved account, call the 'create' method from
    # Devise's ConfirmationsController 
    elsif user.can_post
      super

    # else print appropriate message
    else
      redirect_to new_user_session_path, :notice => "If your e-mail exists on our database, you will receive an email with instructions about how to confirm your account in a few minutes."
    end
    
  end

end
