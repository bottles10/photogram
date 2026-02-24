class SessionsController < ApplicationController
  # Skip the login wall for the login page itself
  skip_before_action :require_login, only: [ :new, :create ]

  def new
    # Renders app/views/sessions/new.html.erb (the login form)
    redirect_to posts_path if logged_in?
  end

  def create
    # ⚠️  VULNERABILITY — SQL Injection (Authentication Bypass)
    #
    # We interpolate params[:username] and params[:password] directly into
    # a raw SQL string. The database cannot distinguish between intended SQL
    # structure and attacker-controlled input.
    #
    # --- ATTACK PAYLOAD ---
    # Username field:  ' OR '1'='1' --
    # Password field:  anything
    #
    # The interpolated query becomes:
    #   SELECT * FROM users
    #   WHERE username = '' OR '1'='1' --' AND password = 'anything' LIMIT 1
    #
    # The -- starts a SQL comment, discarding the password check entirely.
    # The condition '1'='1' is always true, so the WHERE clause always matches.
    # The database returns the first row in the users table (usually the admin).
    # The attacker is now logged in as admin with no valid credentials.
    #
    # --- WHY THIS WORKS ---
    # String interpolation (#{ }) in Ruby just concatenates characters.
    # The single quote in the payload closes the intended string literal,
    # then the injected SQL runs as legitimate database instructions.
    #
    # --- THE FIX ---
    # Use parameterised queries — Rails passes values as separate arguments
    # so the database driver treats them as data, never as SQL structure:
    #   User.where("username = ? AND password = ?", params[:username], params[:password]).first
    # Or even simpler and safer:
    #   User.find_by(username: params[:username], password: params[:password])

    user = User.find_by_sql(
      "SELECT * FROM users " \
      "WHERE username = '#{params[:username]}' " \
      "AND password = '#{params[:password]}' LIMIT 1"
    ).first

    if user
      session[:user_id] = user.id
      redirect_to posts_path, notice: "Welcome back, #{user.username}!"
    else
      flash.now[:alert] = "Incorrect username or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "You have been logged out."
  end
end
