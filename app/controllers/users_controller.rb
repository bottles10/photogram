class UsersController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]

  def new
    redirect_to posts_path if logged_in?
    @user = User.new
  end

  def create
    # ⚠️  VULNERABILITY — Mass Assignment
    #
    # We pass the entire params[:user] hash directly to User.new without
    # a strong-parameters whitelist. If the User model ever gains sensitive
    # columns like `is_admin` or `role`, an attacker can POST extra fields
    # (easily done with curl or Burp Suite) and set their own permissions.
    #
    # Example attack:
    #   curl -X POST http://localhost:3000/signup \
    #     -d "user[username]=hacker&user[password]=1234&user[is_admin]=true"
    #
    # The safe approach uses strong parameters to explicitly whitelist fields:
    #   params.require(:user).permit(:username, :email, :password, :bio)
    @user = User.new(params[:user])

    if @user.save
      session[:user_id] = @user.id
      redirect_to posts_path, notice: "Welcome to VulnGram, #{@user.username}!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user  = User.find(params[:id])
    @posts = @user.posts.order(created_at: :desc)
  end
end
