class DropZeroBinsTable < ActiveRecord::Migration
  def up
    
    # This table has been deprecated for a considerable amount of time.
    # ZeroBins have been stored on the Post table for at least 6 months.
    drop_table :zero_bins
  end

  def down
    create_table :zero_bins do |t|        
      t.string :iv
      t.string :salt
      t.text :ct
      
      t.string :random_token
      t.datetime :burn_after_date
      
      t.timestamps
    end
  end
end
