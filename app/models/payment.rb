class Payment < ActiveRecord::Base
  attr_accessible :card_type, :card_holder_name, :amount, :ip


  def self.paypal_payment(amount)
    begin
      gateway = ActiveMerchant::Billing::PaypalGateway.new(
          :login => DONATION_KEYS['PAYPAL_LOGIN'],
          :password => DONATION_KEYS['PAYPAL_PASSWORD'],
          :signature => DONATION_KEYS['PAYPAL_SIGNATURE']
      )

      credit_card = ActiveMerchant::Billing::CreditCard.new(
          :type => "visa",
          :number => "4024007148673576",
          :verification_value => "123",
          :month => 1,
          :year => Time.now.year+1,
          :first_name => "First Name",
          :last_name => "Last Name"
      )

      if credit_card.valid?
        # or gateway.purchase to do both authorize and capture
        response = gateway.authorize(amount, credit_card, :ip => "127.0.0.1")
        if response.success?
          gateway.capture(amount, response.authorization)
          return true
        else
          return response.errors.full_messages.join('. ')
        end
      else
        return credit_card.errors.full_messages.join('. ')
      end
    rescue Exception => ex
      return ex.message
    end
  end
end
