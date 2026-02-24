class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true

      # ⚠️  VULNERABILITY — Also rendered with raw() — second XSS vector.
      # Comments are stored and then displayed unescaped on every post page.
      t.text :body, null: false

      t.timestamps
    end
  end
end
