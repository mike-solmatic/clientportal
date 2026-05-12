class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.references :invoice, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :payment_method, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.date :payment_date
      t.string :reference
      t.text :notes

      t.timestamps
    end
  end
end
