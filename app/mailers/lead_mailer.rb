class LeadMailer < ApplicationMailer
  def new_lead
    @notification = params[:notification]
    @lead = @notification.lead
    @contact = @lead.contact
    mail(to: @notification.recipient, subject: "New #{@lead.lead_type.humanize.downcase} lead from #{@contact.name.presence || 'a website visitor'}")
  end
end
