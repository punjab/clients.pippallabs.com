class JobApplicationWorkflow
  class Forbidden < StandardError; end
  class InvalidTransition < StandardError; end

  TRANSITIONS = {
    "new" => %w[reviewing rejected withdrawn],
    "reviewing" => %w[interview rejected withdrawn],
    "interview" => %w[offered rejected withdrawn],
    "offered" => %w[hired rejected withdrawn],
    "hired" => [],
    "rejected" => [],
    "withdrawn" => []
  }.freeze

  def self.update(application:, actor:, membership:, status:)
    new(application:, actor:, membership:).update(status:)
  end

  def initialize(application:, actor:, membership:)
    @application = application
    @actor = actor
    @membership = membership
  end

  def update(status:)
    authorize!
    target = status.to_s
    raise InvalidTransition, "unknown application status" unless JobApplication.statuses.key?(target)
    raise InvalidTransition, "cannot move #{application.status.humanize} to #{target.humanize}" unless TRANSITIONS.fetch(application.status).include?(target)

    from_status = application.status
    application.transaction do
      application.update!(status: target)
      application.histories.create!(
        tenant: application.tenant,
        actor:,
        change_type: "status_changed",
        from_status:,
        to_status: target,
        occurred_at: Time.current
      )
    end
    application
  end

  private

  attr_reader :application, :actor, :membership

  def authorize!
    allowed = membership&.can_access_recruiting? && membership.tenant_id == application.tenant_id
    allowed &&= membership.location_id == application.location_id if membership&.location_manager?
    raise Forbidden, "application is outside the current membership scope" unless allowed
  end
end
