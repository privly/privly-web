class Authentication < ActiveRecord::Base
  #todo, generate migration to drop this table entirely
  belongs_to :user

end
