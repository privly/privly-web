class Post < ActiveRecord::Base
  belongs_to :user
  self.per_page = 5
end
