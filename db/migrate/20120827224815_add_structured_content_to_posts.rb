class AddStructuredContentToPosts < ActiveRecord::Migration
  def change
    add_column    :posts, :structured_content, :text
  end
end
