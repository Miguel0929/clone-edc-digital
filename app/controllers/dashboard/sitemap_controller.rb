class Dashboard::SitemapController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def index
    add_breadcrumb "<a class='active' href='#{ dashboard_sitemap_index_path }'>Mapa del sitio</a>".html_safe
  end

end
