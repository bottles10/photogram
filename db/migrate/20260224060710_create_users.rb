class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
       t.string :username, null: false
      t.string :email,    null: false
      t.string :bio,      default: ""

      # ⚠️  VULNERABILITY — Plain-text password storage
      # We store the raw password string instead of a secure bcrypt digest.
      # If an attacker ever dumps this table (e.g. via SQL injection) they
      # get every user's actual password with zero cracking required.
      #
      # The safe approach uses Rails' has_secure_password which stores a
      # bcrypt hash in a column named `password_digest` instead.
      t.string :password, null: false

      t.timestamps
    end
    add_index :users, :username, unique: true
    add_index :users, :email,    unique: true
  end
end
