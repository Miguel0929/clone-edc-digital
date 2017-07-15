class Dashboard::DelireverablesController < ApplicationController
  before_action :authenticate_user!
  add_breadcrumb "EDCDIGITAL", :root_path

  def index
    add_breadcrumb "<a href='#{dashboard_delireverables_path}' class='active'>Mis entregables</a>".html_safe

    @delireverables = Delireverable.joins(delireverable_package: [:groups])
                                    .where('groups.id = ?', current_user.group.id)
                                    .order(position: :asc)
  end
end
