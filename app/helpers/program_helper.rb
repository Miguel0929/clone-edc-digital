module ProgramHelper
  def fetch_programs
    programs = $redis.get("programs")
    if programs.nil?
      programs = Program.all.to_json
      $redis.set("programs", programs)
      $redis.expire("programs", 60.minutes.to_i)
    end
    @programs = JSON.load programs
  end
end
