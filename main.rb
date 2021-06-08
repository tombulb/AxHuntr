require 'sinatra'
require 'sinatra/reloader' if development?
require 'bcrypt'
require_relative 'db/helpers.rb'

enable :sessions

def current_user 
  run_sql("SELECT * FROM users WHERE id = #{session[:user_id]};")[0]
end

def logged_in? 
  if session[:user_id] == nil
    return false
  else
    return true
  end
end


get '/' do
#Search bar. search by model, brand or user.


  #timeline of recent posts. currently showing ALL reviews
  user_reviews = run_sql("SELECT * FROM reviews;").reverse_each
  

  erb :index, locals: {user_reviews: user_reviews}

end

get '/login' do

  #log in form. user inputs email and password. button to submti credentials.

  erb :login_form

end

post '/session' do

  user = run_sql("SELECT * FROM users WHERE email = '#{params["email"]}';")

  if user.count > 0 && BCrypt::Password.new(user[0]["password_digest"]) == params["password"]
    logged_in = user[0] 
    session[:user_id] = logged_in["id"]
    redirect '/'
  else
    erb :login_form
  end


end

delete '/session' do
  
  session[:user_id] = nil
  redirect '/'

end

get '/new_user' do

  erb :new_user_form

end

post '/users' do
#need to confirm if user input is what database is expecting?

#check if email already exists in database.
  user = run_sql("SELECT * FROM users WHERE email = '#{params["email"]}';")
  
  if user.count == 0 #if email not found, inserts new user data into database and logs in.

    password = params["password"]
    password_digest = BCrypt::Password.create(password)
    run_sql("INSERT INTO users (email, password_digest) VALUES ('#{params["email"]}','#{password_digest}');")

    user = run_sql("SELECT * FROM users WHERE email = '#{params["email"]}';")
    logged_in = user[0] 
    session[:user_id] = logged_in["id"]
    redirect '/'
    
  else #if email found, redirects back to log in page
    redirect '/login'
  end

end

get '/account' do

  if !logged_in?

    redirect '/login'
  
  end

  user_reviews = run_sql("SELECT * FROM reviews WHERE user_id = '#{session[:user_id]}';").reverse_each

  erb :user_account, locals: {user_reviews: user_reviews}

end

get '/new_review' do

  if !logged_in?

    redirect '/login'
  
  end

  erb :new_axe_form

end

post '/new' do

  #verify data supplied by user is correct

  # if correct, insert into database
  run_sql("
  INSERT INTO reviews (
    model, 
    rating, 
    image_url, 
    review,
    user_id,
    user_email
    ) values (
      '#{params["model"]}',
      '#{params["rating"]}',
      '#{params["image_url"]}',
      '#{params["review"]}',
      '#{current_user()['id']}',
      '#{current_user()['email']}'
    );
  ");
# if false 
  redirect '/account'

end

get '/search' do



end



