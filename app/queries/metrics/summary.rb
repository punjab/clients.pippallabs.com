module Metrics
  class Summary
    def self.call(tenant:, from:, to:, location_ids: nil)
      new(tenant:, from:, to:, location_ids:).call
    end

    def initialize(tenant:, from:, to:, location_ids: nil)
      @tenant = tenant
      @from = from.to_date
      @to = to.to_date
      @location_ids = Array(location_ids).compact.presence
    end

    def call
      {
        period: { from:, to:, time_zone: tenant.time_zone },
        totals: totals,
        trend: trend,
        top_pages: top_pages,
        top_sources: top_sources,
        locations: location_breakdown
      }
    end

    private

    attr_reader :tenant, :from, :to, :location_ids

    def range
      @range ||= Time.use_zone(tenant.time_zone) { from.beginning_of_day..to.end_of_day }
    end

    def events
      @events ||= begin
        scope = tenant.events.accepted.where(occurred_at: range)
        location_ids ? scope.where(location_id: location_ids) : scope
      end
    end

    def leads
      @leads ||= begin
        scope = tenant.leads.non_spam.where(occurred_at: range)
        location_ids ? scope.where(location_id: location_ids) : scope
      end
    end

    def totals
      visits = events.where(event_type: "page_view").distinct.count(:session_id)
      lead_count = leads.count
      outcomes = leads.where(status: %i[won lost]).count
      won = leads.status_won
      {
        visits:,
        order_intent: events.where(event_type: "order_click").count,
        call_intent: events.where(event_type: "call_click").count,
        coupon_intent: events.where(event_type: "coupon_click").count,
        leads: lead_count,
        won_leads: won.count,
        lost_leads: leads.status_lost.count,
        overdue_follow_ups: leads.merge(Lead.overdue).count,
        lead_conversion_rate: percentage(lead_count, visits),
        win_rate: percentage(won.count, outcomes),
        attributed_value: won.sum(:actual_value).to_s,
        estimated_pipeline: leads.active.sum(:estimated_value).to_s
      }
    end

    def trend
      visits_by_day = events.where(event_type: "page_view").group("DATE(occurred_at)").distinct.count(:session_id)
      leads_by_day = leads.group("DATE(occurred_at)").count
      (from..to).map do |date|
        { date:, visits: visits_by_day.fetch(date, 0), leads: leads_by_day.fetch(date, 0) }
      end
    end

    def top_pages
      page_views = events.where(event_type: "page_view").group(:page_url).count
      intents = events.where.not(event_type: "page_view").group(:page_url).count
      (page_views.keys | intents.keys).map do |page|
        { page_url: page, page_views: page_views.fetch(page, 0), intent: intents.fetch(page, 0) }
      end.sort_by { |row| [ -row[:intent], -row[:page_views], row[:page_url] ] }.first(8)
    end

    def top_sources
      visits = events.where(event_type: "page_view").group(:utm_source).distinct.count(:session_id)
      intent = events.where.not(event_type: "page_view").group(:utm_source).count
      (visits.keys | intent.keys).map do |source|
        { source:, visits: visits.fetch(source, 0), intent: intent.fetch(source, 0) }
      end.sort_by { |row| [ -row[:intent], -row[:visits], row[:source] ] }.first(8)
    end

    def location_breakdown
      scope = tenant.locations.active.order(:name)
      scope = scope.where(id: location_ids) if location_ids
      visits = events.where(event_type: "page_view").group(:location_id).distinct.count(:session_id)
      intent = events.where.not(event_type: "page_view").group(:location_id).count
      lead_counts = leads.group(:location_id).count
      won_counts = leads.status_won.group(:location_id).count
      won_values = leads.status_won.group(:location_id).sum(:actual_value)
      scope.map do |location|
        {
          id: location.id,
          name: location.name,
          visits: visits.fetch(location.id, 0),
          intent: intent.fetch(location.id, 0),
          leads: lead_counts.fetch(location.id, 0),
          won: won_counts.fetch(location.id, 0),
          attributed_value: won_values.fetch(location.id, 0).to_s
        }
      end
    end

    def percentage(numerator, denominator)
      return 0.0 if denominator.zero?

      ((numerator.to_f / denominator) * 100).round(1)
    end
  end
end
