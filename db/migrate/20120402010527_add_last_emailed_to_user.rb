class AddLastEmailedToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.datetime   :last_emailed
    end
  end
end
