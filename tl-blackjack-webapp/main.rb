require 'rubygems'
require 'sinatra'

set :sessions, true

BLACKJACK_AMOUNT = 21

helpers do
	def calculate_total(cards)
		arr = cards.map{|element| element[1]}

		total = 0
		arr.each do |a|
			if a == "A"
				total += 11
			else
				total += a.to_i == 0 ? 10 : a.to_i
			end
		end

		arr.select{|element| element == "A"}.count.times do
			break if total <= BLACKJACK_AMOUNT
			total -= 10
		end

		total
	end

	def card_image(card)
		suits = case card[0]
			when 'H' then 'hearts'
			when 'D' then 'diamonds'
			when 'C' then 'clubs'
			when 'S' then 'spades'
		end

		values = card[1]
		if ['J','Q','K','A'].include?(values)
			values = case card[1]
				when 'J' then 'jack'
				when 'Q' then 'queen'
				when 'K' then 'king'
				when 'A' then 'ace'
			end
		end

		"<img src='/images/cards/#{suits}_#{values}.jpg' style='height: 100px; width: auto;'class='card_image'>"
	end

	def winner!(msg)
		@play_again = true
		@show_hit_or_stay_buttons = false
		@success = "<strong>You won!</strong> #{msg}"
	end

	def loser!(msg)
		@play_again = true
		@show_hit_or_stay_buttons = false
		@error = "<strong>You lost!</strong> #{msg}"
	end

	def tie!(msg)
		@play_again = true
		@show_hit_or_stay_buttons = false
		@error = "<strong>You both tied with #{player_total}!</strong> #{msg}"
	end

end

before do
	@show_hit_or_stay_buttons = true
end

get '/' do
	if session[:player_name]
		redirect '/game'
	else
		redirect '/new_player'
	end	
end

get '/new_player' do
	erb :new_player
end

post '/new_player' do
	if params[:player_name].empty?
		@error = "Name is required"
		halt erb(:new_player)
	end

	session[:player_name] = params[:player_name]
	redirect '/game'
end

get '/game' do
	session[:turn] = session[:player_name]

	suits = ['H','D','C','S']
	values = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
	session[:deck] = suits.product(values).shuffle! # will produce ['H','9']
	
	session[:dealer_cards] = []
	session[:player_cards] = []
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop
	session[:player_cards] << session[:deck].pop
	session[:dealer_cards] << session[:deck].pop	

	erb :game
end

post '/game/player/hit' do
	session[:player_cards] << session[:deck].pop

	player_total = calculate_total(session[:player_cards])
	if player_total == BLACKJACK_AMOUNT
		winner!("You hit blackjack!")
	elsif player_total > BLACKJACK_AMOUNT
		loser!("You busted.")
	end

	erb :game
end

post '/game/player/stay' do
	@success = "You have chosen to stay."
	@show_hit_or_stay_buttons = false
	redirect '/game/dealer'
end

get '/game/dealer' do
	session[:turn] = "dealer"

	dealer_total = calculate_total(session[:dealer_cards])

	if dealer_total == BLACKJACK_AMOUNT
		loser!("Darn, the dealer hit blackjack..better luck next time.")
	elsif dealer_total > BLACKJACK_AMOUNT
		winner!("The dealer busted with a #{dealer_total}.")
	elsif dealer_total >= 17
		redirect '/game/compare'
	else
		@show_dealer_hit_button = true

	end

	erb :game		
end

post '/game/dealer/hit' do
	session[:dealer_cards] << session[:deck].pop
	redirect 'game/dealer'
end

get '/game/compare' do
	show_hit_or_stay_buttons = false

	player_total = calculate_total(session[:player_cards])
	dealer_total = calculate_total(session[:dealer_cards])

	if player_total < dealer_total
		loser!("Your total: #{player_total}. The dealer's total: #{dealer_total}.")
	elsif player_total > dealer_total
		winner!("Your total: #{player_total}. The dealer's total: #{dealer_total}.")
	else
		tie!("")
	end

	erb :game

end

get '/over' do
	erb :game_over
end



