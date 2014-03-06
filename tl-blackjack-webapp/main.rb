require 'rubygems'
require 'sinatra'

set :sessions, true


get '/' do
	"Hello Jody!"
end

get '/test' do
	erb :test_template
end

get '/nested' do
	erb :"/Nested/nested_template"
end
