class User < ApplicationRecord
  has_many :posts,    dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :email,    presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true

  # ⚠️  VULNERABILITY — Broken Authentication (plain-text password comparison)
  #
  # We search the database for an exact username + password match.
  # This means:
  #   a) Passwords are never hashed — they live in the DB as readable strings.
  #   b) The method is called inside SessionsController with raw SQL string
  #      interpolation, making it vulnerable to SQL injection (see that file).
  #
  # Secure replacement:
  #   Add `has_secure_password` to this model (requires password_digest column)
  #   then call  user.authenticate(params[:password])  which runs bcrypt.
  def self.authenticate(username, password)
    # NOTE: This method exists only as documentation of the intended safe path.
    # The actual login query in SessionsController bypasses this entirely and
    # uses raw string interpolation — that is intentional for the demo.
    find_by(username: username, password: password)
  end
end
