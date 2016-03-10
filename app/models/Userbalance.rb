class Userbalance < ParseResource::Base
	  fields :facebookID, :balance

	  validates_presence_of :facebookID, :balance
end