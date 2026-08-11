module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?, :current_user, :current_membership
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    resume_session.present?
  end

  def current_user
    Current.user
  end

  def current_membership
    Current.membership
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    Current.session ||= find_session_by_cookie
  end

  def find_session_by_cookie
    Session.includes(:user, membership: :tenant).find_by(id: cookies.signed[:session_id])
  end

  def request_authentication
    if request.format.json?
      render json: { error: "authentication_required" }, status: :unauthorized
    else
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end
  end

  def start_new_session_for(user, membership: user.memberships.first)
    user.sessions.create!(
      membership: membership,
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    ).tap do |created_session|
      Current.session = created_session
      cookies.signed.permanent[:session_id] = {
        value: created_session.id,
        httponly: true,
        same_site: :lax
      }
    end
  end

  def terminate_session
    Current.session&.destroy
    cookies.delete(:session_id)
  end
end
