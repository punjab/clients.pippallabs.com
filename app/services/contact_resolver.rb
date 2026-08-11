class ContactResolver
  class IdentityConflict < StandardError; end

  def self.call(tenant:, attributes:)
    new(tenant:, attributes:).call
  end

  def initialize(tenant:, attributes:)
    @tenant = tenant
    @attributes = attributes
  end

  def call
    email = Contact.normalize_email(attributes[:email])
    phone = Contact.normalize_phone(attributes[:phone])
    matches = []
    matches.concat(tenant.contacts.where(email:).to_a) if email
    matches.concat(tenant.contacts.where(phone:).to_a) if phone
    matches.uniq!
    raise IdentityConflict, "email and phone belong to different contacts" if matches.many?

    contact = matches.first || tenant.contacts.new
    contact.name = attributes[:name].to_s.strip.presence || contact.name
    contact.email ||= email
    contact.phone ||= phone
    apply_consent(contact)
    contact.save!
    contact
  end

  private

  attr_reader :tenant, :attributes

  def apply_consent(contact)
    timestamp = attributes[:consent_timestamp].presence
    if ActiveModel::Type::Boolean.new.cast(attributes[:email_consent])
      contact.email_consent = true
      contact.email_consent_source = attributes[:consent_source]
      contact.email_consent_at = timestamp
    end
    if ActiveModel::Type::Boolean.new.cast(attributes[:sms_consent])
      contact.sms_consent = true
      contact.sms_consent_source = attributes[:consent_source]
      contact.sms_consent_at = timestamp
    end
  end
end
