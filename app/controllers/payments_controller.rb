class PaymentsController < ApplicationController
  def donate
    amount = params[:amount].to_i
    response = Payment.paypal_payment(amount)
    flash[:alert] = if response == true then
                      "You have successfully donated #{amount} cents through PayPal"
                    else
                      response
                    end
    redirect_to root_path
  end
end
