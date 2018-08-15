require 'sinatra'
require 'json'
require 'sinatra/activerecord'
require './models/account.rb'
require './models/follower.rb'
require './models/interact_join.rb'
require './models/interact.rb'
require './models/post.rb'
require './models/hashtag.rb'
require './models/hashtag_join.rb'
require "securerandom"



enable :sessions
set :database, {adapter: "postgresql", database: "ruby_blog_database"}

get "/" do
    erb :login

end

post "/login-data-portal" do
    puts "--------LOGIN ATTEMPT---------"
    user_input = eval(request.body.read) #<--- get axios post as hash
    #user_input.each do |key, value|
       #value.force_encoding("UTF-8")
    #end
    puts "USER INPUT: " + user_input.to_s 
    puts "------------------------------" 
    puts "------LOGIN SEARCH RESULT----"
    search_result = Account.find_by(email: user_input[:usernameInput])
    
    puts search_result
    puts "------------------------------"
    puts "------RETURN MESSAGE----------"
    if search_result === nil  || (search_result != nil && user_input[:passwordInput] != search_result[:password]) 
        puts "Sorry, we don't recognize this username/password combination. Try signing up?"
        $send_data  = {:error => "ERROR"}
    elsif search_result != nil && (user_input[:passwordInput] === search_result[:password] && search_result[:verified] != true)
        $send_data  = {:error => "ERROR NOT VERIFIED"}
    elsif search_result != nil && (user_input[:passwordInput] === search_result[:password] && search_result[:verified] === true)
        puts "Account Match!"
        puts "Credentials: "
        search_result.attributes.each do |key, value|
            puts "     " + key.to_s + ": " + value.to_s
        end
        $send_data  = search_result.attributes
    end
    puts "------------------------------"
    content_type :json 
    $send_data.to_json 
    
    #eval(request.body.read) <--- get axios post as hash
    #content_type :json      <------send json response
    #{:firstName => account.first_name, :lastName => account.last_name}.to_json 
end

post "/signup-data-portal" do
    puts "--------SIGNUP ATTEMPT---------------"
    user_input = eval(request.body.read)
    puts "USER INPUT: " + user_input.to_s 
    puts "-------------------------------------" 

    puts "--CHECK FOR EXISTING ACCT RESULTS---"
    search_result = Account.find_by(email: user_input[:new_username_input])
    puts search_result
    puts "------------------------------------"
    
    puts "----------RETURN MESSAGE------------"
    if search_result != nil
        puts "An account with this username already exists."
        $send_data_sign_up =  {:code=> "USERNAME TAKEN"}
    else
        puts "This username may be used! An email will be sent with a verify code and an account will be created"
        $send_data_sign_up =  {:code=> "USERNAME FREE, PROCEDE"}
        verify_code_string_generated = false
        while !verify_code_string_generated do
            verify_code_string = SecureRandom.hex 8
            if Account.find_by(verify_code: verify_code_string) === nil
                verify_code_string_generated = true
            end
        end
        Account.create(first_name: 'not set', last_name: 'not set', email: user_input[:new_username_input], password: user_input[:new_password_input], dob: user_input[:new_dob_input], last_accessed: 'n/a', time_logged: 'n/a', verify_code: verify_code_string, verified: false)

        ##GENERATE CODE AND EMAIL WHICH LINKS TO A ROUTE THAT WILL TAKE THE VERIFY CODE AS A PARAM AND UPDATE THE ACCOUNT AS VERIFIED
    end
    puts "------------------------------------"
    content_type :json 
    $send_data_sign_up.to_json 

end