# Require the bundler gem and then call Bundler.require to load in all gems
# listed in Gemfile.

require 'bundler'
Bundler.require

require 'sinatra/cross_origin'

use Rack::Logger

before do
     content_type :json
     headers 'Access-Control-Allow-Origin' => '*',
  		   'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST', 'PUT', 'DELETE'],
  		   'Access-Control-Allow-Headers' => 'Content-Type'
end

configure do
  enable :cross_origin
end

 set :protection, false

# Setup DataMapper with a database URL. On Heroku, ENV['DATABASE_URL'] will be
# set, when working locally this line will fall back to using SQLite in the
# current directory.
DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/wishlist_api_v1")

# Define a simple DataMapper model.
class Wishlist
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :created_at, DateTime
  property :title, String, :length => 255
  property :description, Text
  property :owner_id, Integer
end

class WishlistLink
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :created_at, DateTime
  property :link, String, :length => 255
  property :picture, String, :length => 255
  property :description, String, :length => 255
  property :title, String, :length => 255
  property :wishlist_id, Integer
  property :rate, Integer, :default => 3

end

class User
  include DataMapper::Resource

  property :id, Serial, :key => true
  property :mail, String
  property :password, String
end

# Finalize the DataMapper models.
DataMapper.finalize

# Tell DataMapper to update the database according to the definitions above.
DataMapper.auto_upgrade!

options '/*' do
  200
end

delete '/wishlistslinks/:id' do
  content_type :json
   @thing = WishlistLink.get(params[:id].to_i)

   if @thing.destroy
     {:success => "ok"}.to_json
   else
     halt 500
   end

  #  begin
  #    params.merge! JSON.parse(request.env["rack.input"].read)
  #  rescue JSON::ParserError
  #    logger.error "Cannot parse request body."
  #  end
   #
  #  { result: "#{params[:wishlistslinks]} deleted!", method: 'DELETE' }.to_json
 end

get '/' do
  send_file './public/index.html'
end

# Route to show all users, ordered like a blog
get '/users' do
  content_type :json
  @users = User.all

  @users.to_json
end

# CREATE: Route to create a new User
post '/users' do
  content_type :json

  # These next commented lines are for if you are using Backbone.js
  # JSON is sent in the body of the http request. We need to parse the body
  # from a string into JSON
  # params_json = JSON.parse(request.body.read)

  # If you are using jQuery's ajax functions, the data goes through in the
  # params.
  @user = User.new(params)

  if @user.save
    @user.to_json
  else
    halt 500
  end
end


#----------------------------------------------------------------------------
#--- Login ------------------------------------------------------------------
#----------------------------------------------------------------------------

post '/login' do

  @users = User.all
  @users.each do |user|
    @user = user if user.mail == params[:mail]
  end

  if @user
    if @user.password == params[:password]
      @user.to_json
    else
      halt 404
    end
  else
    @user = User.new(params)

    if @user.save
      @user.to_json
    else
      halt 500
    end
  end

 end
#----------------------------------------------------------------------------
#--- Users ------------------------------------------------------------------
#----------------------------------------------------------------------------

# READ: Route to show a specific User based on its `id`
get '/users/:id' do
  content_type :json
  @user = User.get(params[:id].to_i)

  if @user
    @user.to_json
  else
    halt 404
  end
end


# UPDATE: Route to update a User's mail
put '/users/:id/mail/:mail' do
  content_type :json

  @user = User.get(params[:id].to_i)
  @user.mail = params[:mail]

  if @user.save
    @user.to_json
  else
    halt 500
  end
end

# UPDATE: Route to update a User's password
put '/users/:id/password/:password' do
  content_type :json

  @user = User.get(params[:id].to_i)
  @user.password = params[:password]

  if @user.save
    @user.to_json
  else
    halt 500
  end
end

# DELETE: Route to delete a User
delete '/users/:id/delete' do
  content_type :json
  @user = User.get(params[:id].to_i)

  if @user.destroy
    {:success => "ok"}.to_json
  else
    halt 500
  end
end


#----------------------------------------------------------------------------
#--- Wishlists --------------------------------------------------------------
#----------------------------------------------------------------------------


# Route to show all Things, ordered like a blog
get '/wishlists' do
  content_type :json
  @things = Wishlist.all(:order => :created_at.desc)

  @things.to_json
end

# CREATE: Route to create a new Wishlist
## http://0.0.0.0:9292/wishlists?id=1&created_at=2015-07-20&title=List1&description=C'est ma premiere liste
post '/wishlists' do
  content_type :json

  # These next commented lines are for if you are using Backbone.js
  # JSON is sent in the body of the http request. We need to parse the body
  # from a string into JSON
  # params_json = JSON.parse(request.body.read)

  # If you are using jQuery's ajax functions, the data goes through in the
  # params.
  @thing = Wishlist.new(params)

  if @thing.save
    @thing.to_json
  else
    halt 500
  end
end

# READ: Route to show a specific Wishlist based on its `id`
get '/wishlists/:id' do
  content_type :json
  @thing = Wishlist.get(params[:id].to_i)

  if @thing
    @thing.to_json
  else
    halt 404
  end
end


get '/wishlists/owner_id/:owner_id' do
  content_type :json

  @wls = Wishlist.all
  @wl = []
  @wls.each do |wl|
    @wl.push(wl) if wl.owner_id == params[:owner_id].to_i
  end

  if @wl
    @wl.to_json
  else
    halt 500
  end
end

# READ: Route to show a specific Wishlist based on its `owner_id`
get '/wishlists' do
  content_type :json

  @wls = Wishlist.all
  @wls.each do |wl|
    @wl = wl if wl.owner_id == params[:owner_id]
  end

  if @wl
    @wl.to_json
  else
    halt 404
  end
end

# UPDATE: Route to update a Wishlist's title
put '/wishlists/:id/title/:title' do
  content_type :json

  @thing = Wishlist.get(params[:id].to_i)
  @thing.title = params[:title]

  if @thing.save
    @thing.to_json
  else
    halt 500
  end
end

# UPDATE: Route to update a Wishlist's description
put '/wishlists/:id/description/:description' do
  content_type :json

  @thing = Wishlist.get(params[:id].to_i)
  @thing.description = params[:description]

  if @thing.save
    @thing.to_json
  else
    halt 500
  end
end

# UPDATE: Route to update a Wishlist's owner_id
put '/wishlists/:id/owner_id/:owner_id' do
  content_type :json

  @thing = Wishlist.get(params[:id].to_i)
  @thing.owner_id = params[:owner_id]

  if @thing.save
    @thing.to_json
  else
    halt 500
  end
end

# DELETE: Route to delete a Wishlist
delete '/wishlists/:id/delete' do
  content_type :json
  @thing = Wishlist.get(params[:id].to_i)

  if @thing.destroy
    {:success => "ok"}.to_json
  else
    halt 500
  end
end

#----------------------------------------------------------------------------
#--- WishlistLinks ----------------------------------------------------------
#----------------------------------------------------------------------------

# Route to show all Things, ordered like a blog
get '/wishlistslinks' do
  content_type :json
  @things = WishlistLink.all(:order => :created_at.desc)

  @things.to_json
end

# CREATE: Route to create a new WishlistLink
post '/wishlistslinks' do
  content_type :json


  @page = MetaInspector.new(params[:link])
  params[:picture] = @page.images.best
  params[:description] = @page.description
  params[:title] = @page.title

  # These next commented lines are for if you are using Backbone.js
  # JSON is sent in the body of the http request. We need to parse the body
  # from a string into JSON
  # params_json = JSON.parse(request.body.read)

  # If you are using jQuery's ajax functions, the data goes through in the
  # params.
  @thing = WishlistLink.new(params)

  if @thing.save
    @thing.to_json
  else
    halt 500
  end
end

# READ: Route to show a specific WishlistLink based on its `id`
get '/wishlistslinks/:id' do
  content_type :json
  @thing = WishlistLink.get(params[:id].to_i)

  if @thing
    @thing.to_json
  else
    halt 404
  end
end

get '/wishlistslinks/wishlist_id/:wishlist_id' do
  content_type :json

  @wlls = WishlistLink.all
  @wll = []
  @wlls.each do |wll|
    @wll.push(wll) if wll.wishlist_id == params[:wishlist_id].to_i
  end

  if @wll
    @wll.to_json
  else
    halt 500
  end
end

# UPDATE: Route to update a WishlistLink's link
put '/wishlistslinks/:id/link/:link' do
  content_type :json

  @thing = WishlistLink.get(params[:id].to_i)
  @thing.link = params[:link]

  if @thing.save
    @thing.to_json
  else
    halt 500
  end
end

# UPDATE: Route to update a WishlistLink's wishlist_id
put '/wishlistslinks/:id/wishlist_id/:wishlist_id' do
  content_type :json

  @thing = WishlistLink.get(params[:id].to_i)
  @thing.wishlist_id = params[:wishlist_id]

  if @thing.save
    @thing.to_json
  else
    halt 500
  end
end

put '/wishlistslinks/:id/rate/:rate' do
  content_type :json

  @thing = WishlistLink.get(params[:id].to_i)
  @thing.rate = params[:rate]

  if @thing.save
    @thing.to_json
  else
    halt 500
  end
end

# DELETE: Route to delete a WishlistLink
# delete '/wishlistslinks/:id/delete' do
#   content_type :json
#   @thing = WishlistLink.get(params[:id].to_i)
#
#   if @thing.destroy
#     {:success => "ok"}.to_json
#   else
#     halt 500
#   end
# end
