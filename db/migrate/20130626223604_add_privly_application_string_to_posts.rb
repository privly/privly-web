class AddPrivlyApplicationStringToPosts < ActiveRecord::Migration
  def change
    
    add_column :posts, :privly_application, :string unless Post.column_names.include?('privly_application')
    
    Post.all.each do |post|
      if post.structured_content.nil?
        post.privly_application = "PlainPost"
      else
        post.privly_application = "ZeroBin"
      end
      post.save(:validate => false)
    end
    
  end
end
