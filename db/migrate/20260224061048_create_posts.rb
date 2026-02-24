class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title,     null: false
      t.string :image_url, default: ""

      # ⚠️  VULNERABILITY — This column is rendered with raw() in views
      # meaning any HTML or JavaScript a user enters will execute in
      # every visitor's browser (Stored XSS).
      t.text :caption, null: false

      t.timestamps
    end
  end
end
