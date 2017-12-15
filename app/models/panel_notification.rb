class PanelNotification < ActiveRecord::Base
  belongs_to :user
  enum notification: ["new_program","up_program","up_rubric","shared_file","up_ruta","send_mess","reply_mess", "up_evaluation","more95_student","complete_student","more95_mentor","complete_mentor"]
end
