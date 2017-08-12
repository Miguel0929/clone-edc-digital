class Dashboard::SitemapController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{dashboard_attachments_path}'>Mis archivos</a>".html_safe

  end

end
