class VisitsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin

  def index
    @visits = Visit.all
  end
end
