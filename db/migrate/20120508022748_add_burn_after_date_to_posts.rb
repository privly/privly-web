class AddBurnAfterDateToPosts < ActiveRecord::Migration
  
  #Adds the burn date to the posts table and sets
  #the posts of non-administrative users to 
  #destroy their content in two weeks unless the
  #destruction date is changed
  def change
    
    add_column :posts, :burn_after_date, :datetime
    
    #users = User.where(:admin => false)
    #for user in users
    #  posts = user.posts
    #  for post in posts
    #    post.burn_after_date = Time.now + 14.days
    #    post.save
    #  end
    #end
    
  end
end
