class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :card_type
      t.string :card_holder_name
      t.integer :amount
      t.string :ip

      t.timestamps
    end
  end
end
