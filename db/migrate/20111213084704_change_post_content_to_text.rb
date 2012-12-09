class ChangePostContentToText < ActiveRecord::Migration
  def up
    change_column :posts, :content, :text, :limit => nil
  end

  def down
    change_column :posts, :content, :string
  end
end
