class AddCurrentChallengeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :current_challenge, :string
  end
end
