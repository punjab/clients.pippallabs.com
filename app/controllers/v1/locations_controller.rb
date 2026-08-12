module V1
  class LocationsController < BaseController
    def index
      locations = accessible_locations.active.order(:name)
      render json: locations.as_json(only: %i[id name key active])
    end
  end
end
