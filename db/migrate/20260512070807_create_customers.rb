class CreateCustomers < ActiveRecord::Migration[7.2]
  def change
    create_table :customers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.text :address
      t.string :company_name
      t.text :notes
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
