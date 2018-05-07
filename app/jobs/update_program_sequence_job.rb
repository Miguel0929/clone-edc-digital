class UpdateProgramSequenceJob < ActiveJob::Base
  include SuckerPunch::Job
  include GroupHelper

  def perform(groups)
  	groups.each do |group|
      set_program_order(group)
  	end
  end	

end  	