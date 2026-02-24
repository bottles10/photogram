class CommentsController < ApplicationController
  before_action :require_login

  def create
    @post    = Post.find(params[:post_id])
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @post, notice: "Comment posted!"
    else
      redirect_to @post, alert: "Comment cannot be blank."
    end
  end

  def destroy
    # ⚠️  VULNERABILITY — IDOR (same pattern as PostsController#destroy)
    #
    # No ownership check. Any logged-in user can delete any comment by
    # knowing or guessing its ID.
    #
    # The fix:
    # @comment = current_user.comments.find(params[:id])
    @comment = Comment.find(params[:id])
    @post    = @comment.post
    @comment.destroy
    redirect_to @post, notice: "Comment deleted."
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end