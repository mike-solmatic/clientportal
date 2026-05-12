module ApplicationHelper
  include Pagy::Frontend

  def nav_link(label, path, icon: nil)
    active = current_page?(path) || request.path.start_with?(path.to_s.gsub(/\/[^\/]*$/, ''))
    css = active ? "flex items-center gap-3 px-3 py-2 rounded-lg bg-indigo-700 text-white text-sm font-medium" :
                   "flex items-center gap-3 px-3 py-2 rounded-lg text-indigo-200 hover:bg-indigo-800 hover:text-white text-sm transition-colors"
    link_to path, class: css do
      concat nav_icon(icon)
      concat label
    end
  end

  def admin_nav_link(label, path, icon: nil)
    active = current_page?(path) || request.path.start_with?(path.to_s.gsub(/\/[^\/]*$/, ''))
    css = active ? "flex items-center gap-3 px-3 py-2 rounded-lg bg-slate-700 text-white text-sm font-medium" :
                   "flex items-center gap-3 px-3 py-2 rounded-lg text-slate-300 hover:bg-slate-800 hover:text-white text-sm transition-colors"
    link_to path, class: css do
      concat nav_icon(icon)
      concat label
    end
  end

  def nav_icon(name)
    icons = {
      "grid" => '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"/></svg>',
      "shopping-bag" => '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>',
      "users" => '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>',
      "package" => '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>',
      "store" => '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>'
    }
    raw(icons[name] || "")
  end

  def status_badge(status)
    colors = {
      "draft" => "bg-gray-100 text-gray-700",
      "pending" => "bg-yellow-100 text-yellow-700",
      "confirmed" => "bg-blue-100 text-blue-700",
      "paid" => "bg-green-100 text-green-700",
      "cancelled" => "bg-red-100 text-red-700",
      "sent" => "bg-blue-100 text-blue-700",
      "overdue" => "bg-orange-100 text-orange-700"
    }
    css = colors[status.to_s] || "bg-gray-100 text-gray-700"
    content_tag :span, status.to_s.capitalize, class: "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium #{css}"
  end

  def currency(amount)
    number_to_currency(amount || 0, unit: "$", precision: 2)
  end
end
