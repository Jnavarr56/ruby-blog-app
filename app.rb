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
#set :database, {adapter: "postgresql", database: "ruby_blog_database"}

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
        route = '"http://localhost:4567/verify/' + verify_code_string + '"'
        Pony.mail(
            :from => 'resist@accounts.io',
            :to => user_input[:new_username_input],
            :subject => 'Verify Your Resist.io Account',
            :html_body => '<h1>Hey, you\'re almost there!</h1><br><h3>Click <a href=' + route + '>here</a> to verify your resist.io account.</h3>',
            :via_options => {:port => '25'}
        )
    end
    puts "------------------------------------"
    content_type :json 
    $send_data_sign_up.to_json 
end


get "/verify/:verify_code_from_email" do
    session[:current_user_id] = nil
    @already_verified = false
    account_to_verify = Account.find_by(verify_code:   params["verify_code_from_email"])
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

        @hashtagsTable = Hashtag.all

        @hashtagsJoin = Hashtag_Join.all


        @user_posts = Post.where("user_id = ?", session[:current_user_id])
        puts @user_posts.inspect 
        

        @user_posts = @user_posts.order(created_at: :desc)
        
         
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
    if Account.find_by(id: session[:current_user_id]) != nil
        Account.update(session[:current_user_id], :time_logged => Time.now.utc-session[:log_in_time_UTC])
    else
        puts "Account Missing"
    end
    
    puts "--------------------------------------------"


    session[:current_user_id] = nil

    content_type :json
    {:command => "logging out"}.to_json
end

post "/update-account-portal" do 
    current_user_account = Account.find_by(id: session[:current_user_id])

    puts "----UPDATE ACCOUNT WITH USER INPUT----------"
    user_input = eval(request.body.read)
    puts user_input.inspect
    puts "--------------------------------------------"

    puts "----SEARCH FOR EXISTING ACCOUNTS------------"
    search_existing_accounts_by_username = Account.find_by(email: user_input[:newUsernameInput])
    puts "Existing Account: " +  @search_existing_accounts_by_username.inspect.to_s
    


    if search_existing_accounts_by_username != nil
        $send_data_update_account = {:code => "USERNAME TAKEN"}
        puts "Username Already Exists"
        puts "--------------------------------------------"
    else
        $send_data_update_account = {:code => "USERNAME AVAILABLE"}
        puts "Username Available"
        puts "--------------------------------------------"
    end

    puts "----CHECK CURRENT PASSWORD INPUT------------"
    if current_user_account[:password] !=  user_input[:passwordInput]
        $send_data_update_account = {:code => "CURRENT PASSWORD INCORRECT"}
        puts "Wrong Password"
        puts "--------------------------------------------"
    else
        puts "Correct Password"
        puts "--------------------------------------------"
    end


    update_code_string_generated = false
    while !update_code_string_generated do
        update_code_string = SecureRandom.hex 8
        if Account.find_by(update_code: update_code_string) === nil
            update_code_string_generated = true
        end
    end

    puts "----UPDATING WITH UPDATE CODE---------------"
    puts Account.find_by(id: current_user_account[:id]).inspect
    puts 
    Account.update(current_user_account[:id], :update_code => update_code_string)
    puts Account.find_by(id: current_user_account[:id]).inspect
    current_user_account = Account.find_by(id: current_user_account[:id])
    puts "--------------------------------------------"



    puts "----UPDATING WITH UPDATE USER INPUT---------"
    puts "Before User Input:"
    puts Account.find_by(id: current_user_account[:id]).inspect
    puts "After User Input:"
    Account.update(current_user_account[:id], :new_first_name => user_input[:newFirstNameInput])
    Account.update(current_user_account[:id], :new_last_name => user_input[:newLastNameInput])
    Account.update(current_user_account[:id], :new_email_name => user_input[:newUsernameInput])
    Account.update(current_user_account[:id], :new_passwords => user_input[:newPasswordInput])
    puts Account.find_by(id: current_user_account[:id]).inspect
    puts "--------------------------------------------"

    current_user_account = Account.find_by(id: current_user_account[:id])

    newAccountDataSummary = ""
    if user_input[:newFirstNameInput] === ""
        newAccountDataSummary = newAccountDataSummary + "New First Name: none<br>"
    else
        newAccountDataSummary = newAccountDataSummary + "New First Name: " + user_input[:newFirstNameInput] + "<br>"
    end

    if user_input[:newLastNameInput] === ""
        newAccountDataSummary = newAccountDataSummary + "New Last Name: none<br>"
    else
        newAccountDataSummary = newAccountDataSummary + "New Last Name: " + user_input[:newLastNameInput] + "<br>"
    end

    if user_input[:newUsernameInput] === ""
        newAccountDataSummary = newAccountDataSummary + "New Username/Email: none<br>"
    else
        newAccountDataSummary = newAccountDataSummary + "New Username/Email: " + user_input[:newUsernameInput] + "<br>"
    end
    
    if user_input[:newPasswordInput] === ""
        newAccountDataSummary = newAccountDataSummary + "New Password: none<br>"
    else
        newAccountDataSummary = newAccountDataSummary + "New Password: " + user_input[:newPasswordInput] + "<br><br>"
    end

    
    if $send_data_update_account[:code] === "USERNAME AVAILABLE"
        puts current_user_account[:update_code]
        route = '"http://localhost:4567/verify-update/' + current_user_account[:update_code] + '"'
        Pony.mail(
            :from => 'resist@accounts.io',
            :to => current_user_account[:email],
            :subject => 'Update Your Resist.io Account',
            :html_body => '<h1>Hey, you recently requested a change in account information:</h1><br><br><h3/>' + newAccountDataSummary + 'Click <a href=' + route + '>here</a> to confirm the changes.</h3>',
            :via_options => {:port => '25'}
        )
    end

    content_type :json
    $send_data_update_account.to_json
end

get "/verify-update/:update_verify_code_from_email" do
    session[:current_user_id] =  nil

    puts "----RETRIEVING UPDATE CODE------------------"
    puts params[:update_verify_code_from_email]
    puts "--------------------------------------------"

    puts "----RETRIEVING ACCOUNT TO UPDATE------------"
    account_to_update = Account.find_by(update_code: params[:update_verify_code_from_email])
    puts account_to_update.inspect
    puts "--------------------------------------------"

    puts "----UPDATING ACCOUNT------------"
    puts "Before Update:"
    puts account_to_update.inspect
    puts "After Update:"
    puts account_to_update[:new_email_name]
    if account_to_update[:first_name] != account_to_update[:new_first_name] && account_to_update[:new_first_name] != ""
        Account.update(account_to_update[:id], :first_name => account_to_update[:new_first_name])
    end
    if account_to_update[:last_name] != account_to_update[:new_last_name] && account_to_update[:new_last_name] != ""
        Account.update(account_to_update[:id], :last_name => account_to_update[:new_last_name])
    end
    if account_to_update[:email] != account_to_update[:new_email_name] && account_to_update[:new_email_name] != ""
        Account.update(account_to_update[:id], :email => account_to_update[:new_email_name])
    end
    if account_to_update[:password] != account_to_update[:new_passwords] && account_to_update[:new_passwords] != ""
        Account.update(account_to_update[:id], :password => account_to_update[:new_passwords])
    end
    puts "--------------------------------------------"
    
    account_to_update = Account.find_by(update_code: params[:update_verify_code_from_email])
    @username = account_to_update[:email]

    erb :updated

end


post "/delete-account-portal" do
    #POST HERE TO CHECK PASSWORD AND SEND EMAIL USING PONY WITH VERIFY CODE (CREATE) AS PARAM
    current_user_account = Account.find_by(id: session[:current_user_id])
    user_input = eval(request.body.read)

    puts "--------USER INPUT PASSWORD CHECK-----------"
    puts "Actual: " + current_user_account[:password].to_s
    puts "Input: " + user_input[:passwordInput].to_s
    puts "Result Match: " + (current_user_account[:password] === user_input[:passwordInput]).to_s
    puts "--------------------------------------------"

    if current_user_account[:password] != user_input[:passwordInput]
        $send_data_delete_account = {:code => "PASSWORD INCORRECT"}
    else 
        $send_data_delete_account = {:code => "PASSWORD CORRECT"}
    end


    if $send_data_delete_account[:code] === "PASSWORD CORRECT"
        route = '"http://localhost:4567/verify-delete-account/' + current_user_account[:verify_code] + '"'
        puts "--------USER INPUT DELETION EMAIL-----------"
        puts "Sending delete confirm email with route:"
        puts route
        Pony.mail(
            :from => 'resist@accounts.io',
            :to => current_user_account[:email],
            :subject => 'Delete Your Resist.io Account',
            :html_body => '<h1>Hey, you recently requested a deletion of your account.</h1><br><br><h3>This is irreversible. <br>Click <a href=' + route + '>here</a> to confirm the deletion.</h3>',
            :via_options => {:port => '25'}
        )
        puts "--------------------------------------------"
    
    end
    
    content_type :json
    $send_data_delete_account.to_json


end


get "/verify-delete-account/:verify_delete_code_from_email" do
    session[:current_user_id] =  nil
    #LOCATE ACCOUNT USING PARAM, ACCOUNT.DESTROY, RENDER ERB, LOGOUT
    #FIX TABLES

    puts "--------ACCOUNT TO DELETE LOCATED-----------"
    account_to_delete = Account.find_by(verify_code: params[:verify_delete_code_from_email])

    if account_to_delete === nil
        puts "Account has already been deleted."
        @message = "Account has already been deleted."
    else
        puts "Account to delete located:"
        puts account_to_delete
        puts "Deleting Account"
        @message = "The account for " + account_to_delete[:email] + " has been deleted."
        puts @message
        Account.delete(account_to_delete[:id])
    end
    puts "--------------------------------------------"

    erb :deleted
end

post "/posts-portal" do
    user_input = eval(request.body.read)
    
    puts user_input

    if user_input[:command] === "CREATE"
        if user_input[:user_added_tags] === nil
            Post.create(user_id: session[:current_user_id], post_title: user_input[:post_title], content: user_input[:post_content])
                        
            $posting_return_message = {:code => "POST ADDED"}
        else
            Post.create(user_id: session[:current_user_id], post_title: user_input[:post_title], content: user_input[:post_content])
            created_post = Post.where("user_id = ?", session[:current_user_id]).last
            user_input[:user_added_tags].each do |tag| 
                Hashtag_Join.create(hashtag_id: eval(tag), post_id: created_post[:id])
            end
            $posting_return_message = {:code => "POST ADDED WITH TAGS"}
        end
    end

    if user_input[:command] === "UPDATE"
        puts "HERE"
        updated_post = Post.find_by(id: user_input[:post_to_update])
        updated_post.content = user_input[:new_content]
        updated_post.save
        puts "Updated Post"
    end

    if user_input[:command] === "DELETE"
        puts user_input
        Post.find(user_input[:post_to_delete]).destroy
    end

    
    
    content_type :json
    $posting_return_message.to_json
end

get "/feed" do
    if session[:current_user_id] ===  nil
        redirect "/"
    else
        @sitewidePosts = Post.all
        @sitewidePosts = @sitewidePosts.order(created_at: :desc)

        
        @sitewideUsers = Account.all
        @sitewideUsers = @sitewideUsers.order(created_at: :desc)

        @currentUserID = session[:current_user_id]
        
        @followed_users = Follower.where("following_user_id = ?", @currentUserID)

        @followed_posts = {}
        @followed_users.each do |follow|
            @followed_posts[follow.followed_user_id] = Post.where(user_id: follow.followed_user_id)
        end

        puts @followed_posts.inspect
        
        

        erb :feed
    end
end

get "/posts/:post_id" do
    if session[:current_user_id] ===  nil
        redirect "/"
    else
        @current_post = Post.find(params[:post_id])
        @author = Account.find(@current_post.user_id)

        @tags = []
        Hashtag_Join.where(post_id: params[:post_id]).each do |tag|
            @tags.push(Hashtag.find(tag.hashtag_id).hashtag)
        end

        erb :post
    end
end

get "/users/:view_user_id" do
    if session[:current_user_id] ===  nil
        redirect "/"
    elsif params[:view_user_id].to_i === session[:current_user_id].to_i
        redirect "/"
    else
        @user_to_view = Account.find(params[:view_user_id])
        @user_posts = Post.where("user_id = ?", params[:view_user_id])

        @post_tags = {}

        @user_posts.each do |post|
            tags = []
            Hashtag_Join.where("post_id = ?", post.id).each do |join|
                tags.push(Hashtag.find(join.hashtag_id).hashtag)
            end
            @post_tags[post.id] = tags
        end

        if Follower.find_by(:followed_user_id => @user_to_view.id, :following_user_id => session[:current_user_id]) === nil
            @is_following = "Follow"
        else
            @is_following = "Unfollow"
        end

    
        erb :user
    end
end

post "/follow" do
    if session[:current_user_id] ===  nil
        redirect "/"
    else
        user_input = eval(request.body.read)
        puts user_input

        if user_input[:command] === "FOLLOW"
            Follower.create(following_user_id: session[:current_user_id], followed_user_id: user_input[:user_to_follow])
        else
            Follower.find_by(following_user_id: session[:current_user_id], followed_user_id: user_input[:user_to_unfollow]).destroy
        end 
        
    end
end

post "/friends" do
    if session[:current_user_id] ===  nil
        redirect "/"
    else
        user_input = eval(request.body.read)
        puts user_input

        if user_input[:command] === "FOLLOW"
            Follower.create(following_user_id: session[:current_user_id], followed_user_id: user_input[:user_to_follow])
        else
            Follower.find_by(following_user_id: session[:current_user_id], followed_user_id: user_input[:user_to_unfollow]).destroy
        end 
        
    end
end

get "/friends" do
    if session[:current_user_id] ===  nil
        redirect "/"
    else

        @following = []
        Follower.where("following_user_id = ?", session[:current_user_id]).each do |follow_someone|
            @following.push(Account.find(follow_someone.followed_user_id))
        end

        @followed_by = []
        Follower.where("followed_user_id = ?", session[:current_user_id]).each do |follow_me|
            @followed_by.push(Account.find(follow_me.following_user_id))   
        end


        erb :follow

    end
end