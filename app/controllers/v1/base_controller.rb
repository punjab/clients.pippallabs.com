module V1
  class BaseController < ApplicationController
    protect_from_forgery with: :null_session

    private

    def require_lead_manager!
      return if can_manage_leads?

      render json: { error: "forbidden" }, status: :forbidden
    end
  end
end
