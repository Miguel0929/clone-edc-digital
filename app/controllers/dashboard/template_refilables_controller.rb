class Dashboard::TemplateRefilablesController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a href='#{dashboard_template_refilables_path}' class='active'>Mis rellenables</a>".html_safe

    @refilables = TemplateRefilable.joins(:groups)
                                    .where('groups.id = ?', current_user.group.id)
  end
end
