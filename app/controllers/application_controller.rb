class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # ⚠️  VULNERABILITY — CSRF Protection disabled
  #
  # Rails normally generates a secret token and embeds it as a hidden field
  # in every form. On submission it validates the token, and rejects the
  # request entirely if it's missing or wrong (with: :exception).
  #
  # By switching to :null_session we silently discard the session instead
  # of blocking the request. This means a malicious third-party website can
  # forge requests on behalf of a logged-in user — for example, a hidden
  # auto-submitting form on evil.com that sends DELETE /posts/1, deleting
  # the victim's post without them realising.
  #
  # The safe default is:
  #   protect_from_forgery with: :exception
  protect_from_forgery with: :null_session

  before_action :require_login
  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "Please log in to continue."
    end
  end
end
