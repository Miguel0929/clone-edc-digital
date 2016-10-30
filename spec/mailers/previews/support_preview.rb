# Preview all emails at http://localhost:3000/rails/mailers/support
class SupportPreview < ActionMailer::Preview
  def contact
    Support.contact('No tengo programas', 'No me aparcen los programas', 'Alto', User.first)
  end
end
