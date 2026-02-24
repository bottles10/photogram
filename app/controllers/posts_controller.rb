class PostsController < ApplicationController
  skip_before_action :require_login, only: [ :index, :show ]

  def index
    # ⚠️  VULNERABILITY — SQL Injection (UNION-based data exfiltration)
    #
    # The search term is pasted verbatim into a LIKE clause. An attacker
    # can inject a UNION SELECT to append a second query onto the original,
    # causing the database to return rows from an entirely different table.
    #
    # --- ATTACK PAYLOAD (paste into the search bar) ---
    #
    #   ' UNION SELECT NULL, NULL, username, password, email, NULL, NULL FROM users --
    #
    # PostgreSQL requires that every column pair in a UNION has compatible
    # types.  The posts table schema is:
    #   id(bigint), user_id(bigint), title(varchar), caption(text),
    #   image_url(varchar), created_at(timestamp), updated_at(timestamp)
    #
    # So we place:
    #   NULL        → position 1  (id bigint       — NULL fits any type)
    #   NULL        → position 2  (user_id bigint  — NULL fits any type)
    #   username    → position 3  (title varchar   — both varchar ✓)
    #   password    → position 4  (caption text    — varchar fits text ✓)
    #   email       → position 5  (image_url varchar — both varchar ✓)
    #   NULL        → position 6  (created_at      — NULL fits any type)
    #   NULL        → position 7  (updated_at      — NULL fits any type)
    #
    # The resulting SQL becomes:
    #   SELECT * FROM posts WHERE title LIKE '%'
    #   UNION SELECT NULL, NULL, username, password, email, NULL, NULL FROM users
    #   --%'
    #
    # The database merges both result sets. User rows appear in the feed as
    # if they were posts — "title" shows the username and "caption" shows
    # the plain-text password of every account in the system.
    #
    # This attack chains directly with Vulnerability 3 (plain-text passwords):
    # once you have the passwords you can log in as any user immediately.
    #
    # --- THE FIX ---
    # Pass the value as a separate argument so the driver escapes it:
    #   Post.where("title LIKE ?", "%#{params[:search]}%")

    if params[:search].present?
      @posts = Post.find_by_sql(
        "SELECT * FROM posts WHERE title LIKE '%#{params[:search]}%' ORDER BY created_at DESC"
      )
    else
      @posts = Post.includes(:user).order(created_at: :desc)
    end
  end

  def show
    @post     = Post.find(params[:id])
    @comments = @post.comments.includes(:user).order(created_at: :asc)
    @comment  = Comment.new
  end

  def new
    @post = Post.new
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to @post, notice: "Post shared!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    # ⚠️  VULNERABILITY — IDOR (Insecure Direct Object Reference)
    #
    # We look up the post by the ID in the URL without checking whether
    # it belongs to the currently logged-in user. Any authenticated user
    # can delete any post simply by changing the ID in the request.
    #
    # Attack: while logged in as bob, send:
    #   DELETE /posts/1    (a post that belongs to admin)
    # The post is deleted. Bob is never checked against admin.
    #
    # The fix is to scope the lookup through the current user:
    #   @post = current_user.posts.find(params[:id])
    # This raises ActiveRecord::RecordNotFound if the post does not
    # belong to the requester, which Rails converts to a 404.
    @post = Post.find(params[:id])
    @post.destroy
    redirect_to posts_path, notice: "Post deleted."
  end

  private

  def post_params
    params.require(:post).permit(:title, :caption, :image_url)
  end
end
