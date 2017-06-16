class PanelNotification < ActiveRecord::Base
  belongs_to :user
  enum notification: ["new_program","up_program","up_rubric","shared_file","up_ruta","send_mess","reply_mess"]
end
