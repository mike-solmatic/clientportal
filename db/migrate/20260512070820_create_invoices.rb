class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.references :order, null: false, foreign_key: true
      t.string :invoice_number, null: false
      t.integer :status, default: 0, null: false
      t.date :issued_date
      t.date :due_date
      t.decimal :subtotal, precision: 10, scale: 2, default: 0
      t.decimal :tax, precision: 10, scale: 2, default: 0
      t.decimal :total, precision: 10, scale: 2, default: 0
      t.text :notes

      t.timestamps
    end
  end
end
