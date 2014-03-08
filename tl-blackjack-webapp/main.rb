require 'rubygems'
require 'sinatra'

set :sessions, true

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
			break if total <= 21
			total -= 10
		end

		total
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
	session[:player_name] = params[:player_name]
	redirect '/game'
end

get '/game' do
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
	if calculate_total(session[:player_cards]) > 21
		@error = "Sorry, you busted."
		@show_hit_or_stay_buttons = false
	end

	erb :game
end

post '/game/player/stay' do
	@success = "You have chosen to stay."
	@show_hit_or_stay_buttons = false
	erb :game
end




