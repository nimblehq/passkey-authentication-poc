class CreateCredentials < ActiveRecord::Migration[7.0]
  def change
    create_table :credentials do |t|
      t.references :user, null: false, foreign_key: true
      t.string :external_id
      t.string :public_key
      t.string :label
      t.integer :sign_count

      t.timestamps
    end
    add_index :credentials, :external_id, unique: true
    add_index :credentials, %i[label user_id], unique: true
  end
end
