class ChargesController < ApplicationController

	def index 
	
	end

	def create 
			@amount = params[:amount] || nil
			object_id = params[:user_id] #object_id for installation table
			facebook = Installation.find_by_objectId(object_id).facebookID

			   #if one-time payment
				if @amount 
					userbalance = UserBalance.where(:facebookID => facebook).first
					if userbalance
						userbalance.balance = userbalance.balance.to_f + (@amount.to_f / 10).to_f
						userbalance.save
					else
						ub = UserBalance.new 
						ub.facebookID = facebook
				        ub.balance = (@amount.to_f / 10).to_f
				    end
				    customer = Stripe::Customer.create(
	    	  	 		:email => params[:stripeEmail],
	    				:source  => params[:stripeToken]
	    			)
				    charge = Stripe::Charge.create(
    					:customer    => customer.id,
   					    :amount      => @amount,
   					    :description => 'One Time Charge',
   						:currency    => 'usd'
  						)
			    else

			    #adding card 
			    #check if already card assocation with installation and set invalid in db
			    	
			       if Userpayment.where(:facebookID => facebook).first

			       		userpayments = Userpayment.where(:facebookID => facebook).all
			       		userpayments.each do |payment|
			       			payment.currentCard = false
			       			payment.save
			       		end
			       end

		  		    #create stripe costomer 
		  		    customer = Stripe::Customer.create(
		    		:email => params[:stripeEmail],
		    		:source  => params[:stripeToken]
		  			)
		  		    #create user payment in db
		  			u = Userpayment.new
		  	    	u.facebookID = facebook
					u.stripeCustomerId = customer.id.to_s
					u.currentCard = true
					u.save
					end

		tutors = ["SPfzbYaE4o", "kNMb3H8OZq", "vjs3JDNDFL", "h3dIroU8pk", "6m0g8uGwi7", 
			"tfIOMoDh89", "iGZPdKf8ky", "kPDEEeF1mR", "wzFsMJZbhS", "onuc6zmHK3"].sample(3)
  	
  		@tutors = [ User.where(:objectId => tutors[0]).first , User.where(:objectId => tutors[1]).first, User.where(:objectId => tutors[2]).first]	

		rescue Stripe::CardError => e
  			flash[:error] = e.message
  			redirect_to new_charge_path
	end

	def show

		tutors = ["SPfzbYaE4o", "kNMb3H8OZq", "vjs3JDNDFL", "h3dIroU8pk", "6m0g8uGwi7", 
			"tfIOMoDh89", "iGZPdKf8ky", "kPDEEeF1mR", "wzFsMJZbhS", "onuc6zmHK3"].sample(3)
  	
  		@tutors = [ User.where(:objectId => tutors[0]).first , User.where(:objectId => tutors[1]).first, User.where(:objectId => tutors[2]).first]


		@user = Installation.where(:objectId => params[:id]).first
		@photo = @user.picture

		#Check if already card associated 
		@card_associated = false
		@last_four = nil


		customer = Userpayment.where(:facebookID => @user.facebookID).where(:currentCard => true).first 
		if customer	
			cost = Stripe::Customer.retrieve(:id => customer.stripeCustomerId)
			    if cost.cards.all.data.length > 0
			    	@card_associated = true
			   		@last_four = cost.cards.all.data.first.last4
			   	end

		end
	end

end



