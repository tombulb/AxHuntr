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

  login_msg = "Enter your login details to sign in"

  erb :login_form, locals: {login_msg: login_msg}

end

post '/login' do

  user = run_sql("SELECT * FROM users WHERE email = '#{params["email"]}';")

  if user.count == 0
    login_msg = "That email doesn't exist, try again or hit the sign up button"
  elsif BCrypt::Password.new(user[0]["password_digest"]) != params["password"]
    login_msg = "That password was incorrect, try again"
  else
    logged_in = user[0] 
    session[:user_id] = logged_in["id"]
    redirect '/'
  end

  erb :login_form, locals: {login_msg: login_msg}

end

delete '/session' do
  
  session[:user_id] = nil
  redirect '/'

end

get '/new_user' do

  sign_up_msg = "Complete the form below to sign up"

  erb :new_user_form, locals: {sign_up_msg: sign_up_msg}

end

post '/users' do
#need to confirm if user input is what database is expecting?

  check_for_email = run_sql("SELECT * FROM users WHERE email = '#{params["email"]}';")
  check_for_name = run_sql("SELECT * FROM users WHERE profile_name = '#{params["profile_name"]}';")

  if check_for_name.count > 0
    sign_up_msg = "That profile name already exists, try again"    
  elsif check_for_email.count > 0
    sign_up_msg = "That email already exists, try again"
  else
    password = params["password"]
    password_digest = BCrypt::Password.create(password)

    run_sql("INSERT INTO users (
      profile_name, email, password_digest, img_url
      ) VALUES (
        '#{params["profile_name"]}',
        '#{params["email"]}',
        '#{password_digest}',
        'https://res.cloudinary.com/diore1f83/image/upload/v1623248774/wd5annkmnx1vulbyb9jq.png' 
    );")

    user = run_sql("SELECT * FROM users WHERE email = '#{params["email"]}';")
    logged_in = user[0] 
    session[:user_id] = logged_in["id"]
    redirect '/user_created' 

  end

  erb :new_user_form, locals: {sign_up_msg: sign_up_msg}

end

get '/user_created' do

  erb :user_created

end

get '/account' do

  redirect '/login' if !logged_in?

  user_reviews = run_sql("SELECT * FROM reviews WHERE user_id = '#{session[:user_id]}';").reverse_each
  user = run_sql("SELECT * FROM users WHERE id = '#{current_user()["id"]}';")[0] 

  erb :user_account, locals: {user_reviews: user_reviews, user: user}

end

get '/new_review' do

  redirect '/login' if !logged_in?

  erb :new_review_form

end

options = {
  cloud_name: "diore1f83",
  api_key: "713946916876186",
  api_secret: "#{ENV['API_SECRET']}" 
}

post '/new' do

  review_img = Cloudinary::Uploader.upload(params['review_img']['tempfile'], options)
  
  run_sql("
  INSERT INTO reviews (
    model, 
    rating, 
    img_name,
    img_url, 
    review,
    user_id,
    author
    ) values (
      '#{params["model"]}',
      '#{params["rating"]}',
      '#{params["review_img"]["filename"]}',
      '#{review_img["url"]}',
      '#{params["review"]}',
      '#{current_user()['id']}',
      '#{current_user()['profile_name']}'
    );
  ");

  redirect '/account'

end

get '/account/:id/edit_profile' do

user = run_sql("SELECT * FROM users WHERE id = '#{params["id"]}';")[0]



erb :edit_profile_form, locals: {user: user}

end

put '/account/:id/edit' do

  run_sql("UPDATE users SET
    profile_name='#{params["profile_name"]}',
    email='#{params["email"]}',
    dob='#{params["dob"]}',
    locale='#{params["locale"]}',
    gear='#{params["gear"]}'
      WHERE id = #{params["id"]}
  ;")

  redirect '/account'


end

get '/account/:id/update_profile_pic' do

  user = run_sql("SELECT img_url FROM users WHERE id = '#{params["id"]}';")[0]

  erb :update_avatar_form, locals: {user: user}

end

put '/account/:id/update_profile_pic' do

  res = Cloudinary::Uploader.upload(params['avatar']['tempfile'], options)

  run_sql("UPDATE users SET 
    img_url='#{res["url"]}'
      WHERE id = #{params["id"]}
  ;")

  redirect '/account'

end

get '/account/:id/update_password' do

  user = run_sql("SELECT * FROM users WHERE id = '#{params["id"]}';")[0]

  password_msg = "Update your password below"

  erb :update_password_form, locals: {user: user, password_msg: password_msg}

end

put '/account/:id/update_password' do

  user = run_sql("SELECT * FROM users WHERE id = '#{params["id"]}';")[0]

  if BCrypt::Password.new(user["password_digest"]) != params["curr_password"]
    password_msg = "current password incorrect"
  elsif params["new_password"] != params["new_password_conf"]
    password_msg = "new password doesn't match confirmation"
  elsif params["new_password"] == params["curr_password"]
    password_msg = "New password can't match current password"
  else
    password_digest = BCrypt::Password.create(params["new_password"])

    run_sql("Update users SET
      password_digest='#{password_digest}'
      WHERE id = #{params["id"]};
    ")

    redirect '/password_updated'
  end

  erb :update_password_form, locals: {user: user, password_msg: password_msg}
  

end

get '/password_updated' do

  erb :password_updated

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
  ;")

  redirect '/account'

end


delete '/review/:id' do

  redirect '/login' if !logged_in?

  delete_review = run_sql("DELETE FROM reviews WHERE id = '#{params["id"]}';")

  redirect '/account'

end


get '/search' do



end



