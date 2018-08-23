require './app.rb'
run Sinatra::Application

#set :public_folder, File.join(APP_ROOT, "public")
APP_ROOT = File.expand_path(File.dirname(__FILE__)) unless defined?(APP_ROOT)
