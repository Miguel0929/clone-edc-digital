require 'net/http'

class BaasstardNotifier
  def self.user_invited(user)
    uri = URI('http://baasstard.com/api/edc/user_invited')
    res = Net::HTTP.post_form(uri, { email: user.email })
  end

  def self.user_accepted(user)
    uri = URI('http://baasstard.com/api/edc/user_accepted')
    res = Net::HTTP.post_form(uri, { email: user.email })
  end
end
