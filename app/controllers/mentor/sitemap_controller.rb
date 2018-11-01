class Mentor::SitemapController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb (ENV['COMPANY_NAME'].nil? ? "Inicio" : ENV['COMPANY_NAME']), :root_path

  def index
    add_breadcrumb "<a class='active' href='#{ mentor_sitemap_index_path }'>Mapa del sitio</a>".html_safe
    @group_one = current_user.groups.first
	@program_one = @group_one.all_programs.first
	@student_one = @group_one.students.where.not(invitation_accepted_at: nil).first
	
  end

end
