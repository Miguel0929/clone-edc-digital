class Mobile::ContentsController < Mobile::BaseController
  layout 'mobile'
  skip_after_action :intercom_rails_auto_include
  before_action :authorize

  def show
    @content = ChapterContent.find(params[:id])
  end
end
