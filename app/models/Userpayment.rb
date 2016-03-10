class Userpayment < ParseResource::Base
	  fields :facebookID, :stripeCustomerId, :currentCard

	  validates_presence_of :facebookID, :stripeCustomerId, :currentCard 
end