require 'weborb/context'
require 'weborb/log'

class ContactList
  def getList()
    Contact.find(:all).map { |c| { 'name' => c.name, 'email' => c.email, 'telephone' => c.telephone } }
  end
end