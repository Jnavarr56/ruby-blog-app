require './app.rb'
run Sinatra::Application


APP_ROOT = File.expand_path(File.dirname(__FILE__)) unless defined?(APP_ROOT)
set :public_folder, File.join(APP_ROOT, "public")