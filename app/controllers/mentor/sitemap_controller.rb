class Mentor::SitemapController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a class='active' href='#{ mentor_sitemap_index_path }'>Mapa del sitio</a>".html_safe
  end

end
