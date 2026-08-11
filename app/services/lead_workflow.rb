class LeadWorkflow
  class InvalidTransition < StandardError; end
  class Forbidden < StandardError; end

  TRANSITIONS = {
    "new" => %w[contacted spam],
    "contacted" => %w[quoted spam],
    "quoted" => %w[won lost spam]
  }.freeze

  def self.update(lead:, actor:, membership:, attributes:)
    new(lead:, actor:, membership:).update(attributes)
  end

  def self.add_note(lead:, actor:, membership:, note:)
    new(lead:, actor:, membership:).add_note(note)
  end

  def self.reopen(lead:, actor:, membership:)
    new(lead:, actor:, membership:).reopen
  end

  def initialize(lead:, actor:, membership:)
    @lead = lead
    @actor = actor
    @membership = membership
  end

  def update(attributes)
    authorize!
    attributes = attributes.to_h.symbolize_keys
    raise InvalidTransition, "terminal leads must be explicitly reopened" if lead.terminal? && attributes.slice(*audited_keys).values.any?(&:present?)

    histories = []
    lead.transaction do
      histories << change_status(attributes) if attributes[:status].present? && attributes[:status] != lead.status
      histories << change_owner(attributes) if attributes.key?(:owner_id) && attributes[:owner_id].to_s != lead.owner_id.to_s
      histories << change_location(attributes) if attributes.key?(:location_id) && attributes[:location_id].to_s != lead.location_id.to_s
      histories << change_follow_up(attributes) if attributes.key?(:follow_up_at) && parsed_time(attributes[:follow_up_at]) != lead.follow_up_at
      histories << change_values(attributes) if value_change?(attributes)
      lead.save!
      histories.compact.each(&:save!)
    end
    lead
  end

  def add_note(note)
    authorize!
    raise ActiveRecord::RecordInvalid, lead.tap { |record| record.errors.add(:note, "cannot be blank") } if note.blank?

    lead.histories.create!(tenant: lead.tenant, actor:, change_type: "note_added", note: note.to_s.strip, occurred_at: Time.current)
  end

  def reopen
    authorize!
    raise InvalidTransition, "only terminal leads can be reopened" unless lead.terminal?

    from_status = lead.status
    lead.transaction do
      lead.update!(status: :new, closed_at: nil, lost_reason: nil)
      lead.histories.create!(tenant: lead.tenant, actor:, change_type: "reopened", from_status:, to_status: "new", occurred_at: Time.current)
    end
    lead
  end

  private

  attr_reader :lead, :actor, :membership

  def audited_keys
    %i[status owner_id location_id follow_up_at estimated_value actual_value lost_reason]
  end

  def authorize!
    allowed = membership&.can_manage_leads? && membership.tenant_id == lead.tenant_id
    allowed &&= membership.accessible_locations.where(id: lead.location_id).exists? if membership.location_manager?
    raise Forbidden, "lead is outside the current membership scope" unless allowed
  end

  def change_status(attributes)
    to_status = attributes[:status].to_s
    allowed = TRANSITIONS.fetch(lead.status, [])
    raise InvalidTransition, "cannot move from #{lead.status.humanize} to #{to_status.humanize}" unless allowed.include?(to_status)

    from_status = lead.status
    lead.status = to_status
    lead.lost_reason = attributes[:lost_reason].to_s.strip.presence if to_status == "lost"
    lead.actual_value = parse_money(attributes[:actual_value]) if to_status == "won" && attributes.key?(:actual_value)
    lead.closed_at = Time.current if Lead::TERMINAL_STATUSES.include?(to_status)
    history("status_changed", from_status:, to_status:, changeset: { lost_reason: lead.lost_reason, actual_value: lead.actual_value })
  end

  def change_owner(attributes)
    owner = attributes[:owner_id].present? ? membership.tenant.users.find(attributes[:owner_id]) : nil
    before = lead.owner_id
    lead.owner = owner
    history("assigned", changeset: { from_owner_id: before, to_owner_id: owner&.id })
  end

  def change_location(attributes)
    location = attributes[:location_id].present? ? membership.accessible_locations.find(attributes[:location_id]) : nil
    before = lead.location_id
    lead.location = location
    history("assigned", changeset: { from_location_id: before, to_location_id: location&.id })
  end

  def change_follow_up(attributes)
    before = lead.follow_up_at
    lead.follow_up_at = parsed_time(attributes[:follow_up_at])
    history("follow_up_set", changeset: { from: before, to: lead.follow_up_at })
  end

  def change_values(attributes)
    before = { estimated_value: lead.estimated_value, actual_value: lead.actual_value }
    lead.estimated_value = parse_money(attributes[:estimated_value]) if attributes.key?(:estimated_value)
    lead.actual_value = parse_money(attributes[:actual_value]) if attributes.key?(:actual_value) && lead.status_won?
    history("values_changed", changeset: { from: before, to: { estimated_value: lead.estimated_value, actual_value: lead.actual_value } })
  end

  def value_change?(attributes)
    estimated = attributes.key?(:estimated_value) && parse_money(attributes[:estimated_value]) != lead.estimated_value
    actual = attributes.key?(:actual_value) && parse_money(attributes[:actual_value]) != lead.actual_value
    estimated || actual
  end

  def history(change_type, from_status: nil, to_status: nil, changeset: {})
    lead.histories.build(tenant: lead.tenant, actor:, change_type:, from_status:, to_status:, changeset:, occurred_at: Time.current)
  end

  def parsed_time(value)
    value.present? ? Time.zone.parse(value.to_s) : nil
  rescue ArgumentError
    raise InvalidTransition, "follow-up time is invalid"
  end

  def parse_money(value)
    return if value.blank?

    BigDecimal(value.to_s.delete(","))
  rescue ArgumentError
    raise InvalidTransition, "value is invalid"
  end
end
