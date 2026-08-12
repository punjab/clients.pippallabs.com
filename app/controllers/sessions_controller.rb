class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    user = User.authenticate_by(params.permit(:email_address, :password))

    if user && (user.super_admin? || user.memberships.exists?)
      start_new_session_for(user)
      redirect_to session.delete(:return_to_after_authenticating) || root_path
    else
      redirect_to new_session_path, alert: "Check your email and password."
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  def switch
    if current_user.super_admin? && params[:tenant_id].present?
      tenant = Tenant.find(params[:tenant_id])
      Current.session.update!(tenant:, membership: current_user.memberships.find_by(tenant:))
    else
      membership = current_user.memberships.find(params[:membership_id])
      Current.session.update!(membership:, tenant: membership.tenant)
    end
    redirect_to root_path, notice: "Switched to #{Current.session.tenant.name}."
  end
end
