require 'sinatra'
require 'sinatra/reloader' if development?
require 'bcrypt'
require_relative 'db/helpers.rb'
require 'active_support'
require 'action_view'
require 'cloudinary'
include CloudinaryHelper


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
  login_error = "Please enter your login details below"

  #log in form. user inputs email and password. button to submti credentials.

  erb :login_form, locals: {login_error: login_error}

end

post '/session' do

  


  user = run_sql("SELECT * FROM users WHERE email = '#{params["email"]}';")

  if user.count == 0
    login_error = "That email doesn't exist, try again"
  elsif BCrypt::Password.new(user[0]["password_digest"]) != params["password"]
    login_error = "That password was incorrect, try again"
  else
    logged_in = user[0] 
    session[:user_id] = logged_in["id"]
    redirect '/'
  end

  erb :login_form, locals: {login_error: login_error}

  # if user.count > 0 && BCrypt::Password.new(user[0]["password_digest"]) == params["password"]
    
  # else
  #   
  # end


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
    redirect '/user_created'
    
  else #if email found, redirects back to log in page
    redirect '/login'
  end

end

get '/user_created' do

  erb :user_created

end

get '/account' do

  redirect '/login' if !logged_in?

  user_reviews = run_sql("SELECT * FROM reviews WHERE user_id = '#{session[:user_id]}';").reverse_each

  erb :user_account, locals: {user_reviews: user_reviews}

end

get '/new_review' do

  redirect '/login' if !logged_in?

  erb :new_axe_form

end

options = {
  cloud_name: "diore1f83",
  api_key: "713946916876186",
  api_secret: "1MHVmkiKUOVNDaK8DhV9tZeikCs"
  # api_secret: "#{ENV['API_SECRET']}"
}

post '/new' do

  #verify data supplied by user is correct
  res = Cloudinary::Uploader.upload(params['review_img']['tempfile'], options)
  
  # if correct, insert into database
  run_sql("
  INSERT INTO reviews (
    model, 
    rating, 
    img_name,
    img_url, 
    review,
    user_id,
    user_email
    ) values (
      '#{params["model"]}',
      '#{params["rating"]}',
      '#{params["review_img"]["filename"]}',
      '#{res["url"]}',
      '#{params["review"]}',
      '#{current_user()['id']}',
      '#{current_user()['email']}'
    );
  ");
# if false 
  redirect '/account'

end

get '/reviews/:id/edit' do

  res = run_sql("SELECT * FROM reviews WHERE id = '#{params["id"]}';")
  review=res[0]

  erb :edit_review_form, locals: {review: review}

end

put '/reviews/:id' do

  run_sql("UPDATE reviews SET 
    model='#{params["model"]}',
    rating='#{params["rating"]}',
    review='#{params["review"]}' 
      WHERE id = #{params["id"]}
  ")


  redirect '/account'

end


delete '/review/:id' do

  redirect '/login' if !logged_in?

  delete_review = run_sql("DELETE FROM reviews WHERE id = '#{params["id"]}';")

  redirect '/account'

end


get '/search' do



end



