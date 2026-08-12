module ApplicationHelper
  def nav_link(label, path, icon_name)
    active = current_page?(path) || (path != root_path && request.path.start_with?(path))
    classes = active ? "bg-slate-900 text-white shadow-sm" : "text-slate-500 hover:bg-slate-100 hover:text-slate-900"
    link_to path, class: "flex items-center gap-3 rounded-xl px-3 py-2.5 text-sm font-semibold transition #{classes}" do
      icon(icon_name, class_name: "h-4 w-4") + tag.span(label)
    end
  end

  def icon(name, class_name: "h-5 w-5")
    paths = {
      overview: '<path d="M3 13h8V3H3v10Zm0 8h8v-5H3v5Zm11 0h7V11h-7v10Zm0-18v5h7V3h-7Z"/>',
      leads: '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="m16 11 2 2 4-4"/>',
      locations: '<path d="M20 10c0 5-8 12-8 12S4 15 4 10a8 8 0 1 1 16 0Z"/><circle cx="12" cy="10" r="3"/>',
      insights: '<path d="M3 3v18h18"/><path d="m7 16 4-5 4 3 5-7"/>',
      reports: '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8Z"/><path d="M14 2v6h6M8 13h8M8 17h6"/>',
      recruiting: '<path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M19 8v6M22 11h-6"/>',
      settings: '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .34 1.88l.06.06-2.83 2.83-.06-.06a1.7 1.7 0 0 0-1.88-.34 1.7 1.7 0 0 0-1.03 1.56V21h-4v-.08A1.7 1.7 0 0 0 9 19.37a1.7 1.7 0 0 0-1.88.34l-.06.06-2.83-2.83.06-.06A1.7 1.7 0 0 0 4.63 15 1.7 1.7 0 0 0 3.08 14H3v-4h.08A1.7 1.7 0 0 0 4.63 9a1.7 1.7 0 0 0-.34-1.88l-.06-.06 2.83-2.83.06.06A1.7 1.7 0 0 0 9 4.63h.01A1.7 1.7 0 0 0 10 3.08V3h4v.08A1.7 1.7 0 0 0 15 4.63a1.7 1.7 0 0 0 1.88-.34l.06-.06 2.83 2.83-.06.06A1.7 1.7 0 0 0 19.37 9v.01A1.7 1.7 0 0 0 20.92 10H21v4h-.08A1.7 1.7 0 0 0 19.4 15Z"/>',
      arrow: '<path d="m9 18 6-6-6-6"/>',
      calendar: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 11h18"/>'
    }
    tag.svg(paths.fetch(name).html_safe, class: class_name, viewBox: "0 0 24 24", fill: name == :overview ? "currentColor" : "none", stroke: name == :overview ? "none" : "currentColor", stroke_width: 1.8, aria: { hidden: true })
  end

  def status_badge(status)
    classes = {
      "new" => "bg-blue-50 text-blue-700 ring-blue-600/10",
      "contacted" => "bg-violet-50 text-violet-700 ring-violet-600/10",
      "quoted" => "bg-amber-50 text-amber-800 ring-amber-600/20",
      "won" => "bg-emerald-50 text-emerald-700 ring-emerald-600/10",
      "lost" => "bg-rose-50 text-rose-700 ring-rose-600/10",
      "spam" => "bg-slate-100 text-slate-500 ring-slate-500/10",
      "reviewing" => "bg-violet-50 text-violet-700 ring-violet-600/10",
      "interview" => "bg-cyan-50 text-cyan-700 ring-cyan-600/10",
      "offered" => "bg-amber-50 text-amber-800 ring-amber-600/20",
      "hired" => "bg-emerald-50 text-emerald-700 ring-emerald-600/10",
      "rejected" => "bg-rose-50 text-rose-700 ring-rose-600/10",
      "withdrawn" => "bg-slate-100 text-slate-500 ring-slate-500/10"
    }
    tag.span(status.humanize, class: "inline-flex rounded-full px-2.5 py-1 text-xs font-bold ring-1 ring-inset #{classes.fetch(status, classes['spam'])}")
  end

  def money(value)
    numeric = value.to_d
    number_to_currency(numeric, precision: numeric.frac.zero? ? 0 : 2)
  end

  def initials(name)
    name.to_s.split.first(2).map { |part| part.first }.join.upcase
  end

  def next_status_options(lead)
    LeadWorkflow::TRANSITIONS.fetch(lead.status, []).map { |status| [ status.humanize, status ] }
  end

  def next_job_application_status_options(application)
    JobApplicationWorkflow::TRANSITIONS.fetch(application.status).map { |status| [ status.humanize, status ] }
  end
end
