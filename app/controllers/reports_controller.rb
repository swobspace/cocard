class ReportsController < ApplicationController
  def duplicate_terminal_ips
    add_breadcrumb("Doppelte IPs (CT)", reports_duplicate_terminal_ips_path)
    @duplicate_ips = CardTerminal.where("ip IS NOT NULL and ip <> '0.0.0.0'")
                                 .select("ip, count(*) as count")
                                 .group("ip").having("count(*) > 1")
                                 .order(:ip)
                                 .pluck(:ip).map(&:to_s)
    @card_terminals = CardTerminal.where(ip: @duplicate_ips)
  end
end
