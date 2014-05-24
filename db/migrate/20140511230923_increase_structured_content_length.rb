class IncreaseStructuredContentLength < ActiveRecord::Migration
  def up
    
    # Increase the size of storage for structured content. MySQL will default
    # to shorter text.
    change_column :posts, :structured_content, :text, :limit => 15.megabytes
  end

  def down
    change_column :posts, :structured_content, :text
  end
end
