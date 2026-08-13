class NewsletterController < ApplicationController
  def show
    @signups = scoped_signups.includes(:contact).order(created_at: :desc)

    respond_to do |format|
      format.html
      format.csv do
        send_data signups_csv(@signups), filename: "newsletter-signups-#{Date.current.iso8601}.csv", type: "text/csv"
      end
    end
  end

  private

  def scoped_signups
    scope = current_tenant.leads.newsletter
    location_scoped? ? scope.where(location_id: current_membership.location_id) : scope
  end

  def signups_csv(signups)
    rows = signups.map do |signup|
      [ signup.contact.email, signup.contact.email_consent, signup.contact.email_consent_at&.iso8601, signup.occurred_at.iso8601 ]
    end
    ([ %w[email consent consent_at signed_up_at] ] + rows).map { |row| row.map { |field| csv_field(field) }.join(",") }.join("\n") + "\n"
  end

  def csv_field(value)
    text = value.to_s
    text.match?(/[",\n]/) ? "\"#{text.gsub('"', '""')}\"" : text
  end
end
