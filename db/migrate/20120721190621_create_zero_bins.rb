class CreateZeroBins < ActiveRecord::Migration
  def change
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
