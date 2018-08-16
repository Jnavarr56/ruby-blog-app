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
require 'securerandom'
require 'pony'



enable :sessions
set :database, {adapter: "postgresql", database: "ruby_blog_database"}

get "/" do
    if session[:current_user_id] ===  nil
        erb :login
    else
        redirect "/dashboard"
    end
end

post "/login-data-portal" do #<---LOG IN PAGE WITH VALIDATION
    puts "--------LOGIN ATTEMPT---------"
    user_input = eval(request.body.read) #get axios post as hash
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
        session[:current_user_id] = search_result[:id]
        puts session.inspect
        puts "Account Match!"
        puts "Credentials: "
        search_result.attributes.each do |key, value|
            puts "     " + key.to_s + ": " + value.to_s
        end
        $send_data  = {:error => "NO ERROR"}
    end
    puts "------------------------------"
    
    content_type :json #send hash as json
    $send_data.to_json
end

post "/signup-data-portal" do #<---SIGN UP PAGE WITH VALIDATION
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
        Account.create(first_name: 'not set', last_name: 'not set', email: user_input[:new_username_input], password: user_input[:new_password_input], dob: user_input[:new_dob_input], time_logged: 'n/a', verify_code: verify_code_string, verified: false)
        Pony.mail(
            :from => 'resist@accounts.io',
            :to => user_input[:new_username_input],
            :subject => 'Verify Your Resist.io Account',
            :html_body => '<h1>Hey, you\'re almost there!</h1><br><h3>Click <a href=' + 'http://localhost:4567/verify/' + verify_code_string + '>here</a> to verify your resist.io account.</h3>'
        )
    end
    puts "------------------------------------"
    content_type :json 
    $send_data_sign_up.to_json 
end


get "/verify/:verify_code_from_email" do
    session[:current_user_id] = nil
    @already_verified = false
    account_to_verify = Account.find_by(verify_code: params["verify_code_from_email"])
    if account_to_verify[:verified] === true
        @already_verified = false
    end

    puts "------LOCATED UNVERIFIED ACCOUNT------------"
    puts account_to_verify.inspect
    puts "--------------------------------------------"
    
    puts "---CHANGE VERIFICATION VALUE TO VERIFIED----"
    Account.update(account_to_verify[:id], :verified => true)
    account_to_verify = Account.find_by(verify_code: params["verify_code_from_email"])
    
    puts account_to_verify.inspect
    puts "--------------------------------------------"

    @username = account_to_verify[:email]
    puts @username

    erb :verified
end

get "/dashboard" do
    if session[:current_user_id] !=  nil
        puts "----------USER LOGGING IN-------------------"
        @current_user_account = Account.find_by(id: session[:current_user_id])
        puts @current_user_account.inspect
        puts "--------------------------------------------"

        puts "----------TIME OF USER LOG IN---------------"        
        session[:log_in_time_UTC] = Time.now.utc
        puts session[:log_in_time_UTC] 
        puts "--------------------------------------------"
        erb :dashboard
    else
        redirect "/"
    end
end

post "/log-out" do
    puts "--------DURATION OF USER SESSION------------"
    puts "Log In Time" + (session[:log_in_time_UTC]).to_s
    puts "Log Out Time:" + (Time.now.utc).to_s
    puts "Duration: " + (Time.now.utc-session[:log_in_time_UTC]).to_s
    puts "--------------------------------------------"

    puts "----UPDATE ACCOUNT WITH DURATION------------"
    Account.update(session[:current_user_id], :time_logged => Time.now.utc-session[:log_in_time_UTC])
    puts "--------------------------------------------"


    session[:current_user_id] = nil

    content_type :json
    {:command => "logging out"}.to_json
end

