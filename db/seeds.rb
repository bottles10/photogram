# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


puts "Seeding users..."

admin = User.create!(
  username: "admin",
  email:    "admin@vulngram.local",
  password: "admin123",
  bio:      "I run this place."
)

alice = User.create!(
  username: "alice",
  email:    "alice@vulngram.local",
  password: "password1",
  bio:      "Photography enthusiast 📸"
)

bob = User.create!(
  username: "bob",
  email:    "bob@vulngram.local",
  password: "password2",
  bio:      "Just here for the memes."
)

puts "Seeding posts..."

Post.create!(
  user:      admin,
  title:     "Welcome to Photogram",
  caption:   "Photogram is where you share about your explores!",
  image_url: "https://picsum.photos/seed/admin/600/400"
)

Post.create!(
  user:      alice,
  title:     "Golden Hour",
  caption:   "Caught the perfect light this evening.",
  image_url: "https://picsum.photos/seed/alice/600/400"
)

Post.create!(
  user:      bob,
  title:     "Monday Vibes",
  caption:   "Send help.",
  image_url: "https://picsum.photos/seed/bob/600/400"
)

puts "Seeding comments..."

Comment.create!(user: alice, post: Post.first, body: "Great post!")
Comment.create!(user: bob,   post: Post.first, body: "Looking forward to exploring this.")

puts "Done! Seeded #{User.count} users, #{Post.count} posts, #{Comment.count} comments."