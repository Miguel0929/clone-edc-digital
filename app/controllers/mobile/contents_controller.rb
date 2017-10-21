class Mobile::ContentsController < Mobile::BaseController
  layout 'mobile'
  skip_after_action :intercom_rails_auto_include

  def show
    @content = ChapterContent.find(params[:id])
  end
end
