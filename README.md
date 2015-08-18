# Sinatra JSON API

First run `bundle install`

To launch project run `postgres -D /usr/local/var/postgres/` 

Then `bundle exec rackup`

## Routes
### GET
`/users` get all users

`/wishlists` get all wishlists

`/wishlistslinks` get all wishlist links

You can get a specific user by id like `/users/:id`

Same for `/wishlist/:id` and `/wishlistlinks/:id`

You can get a specific wishlist by user like `/wishlists/owner_id/:id`

And the same for the wishlist links by wishlist `/wishlistslinks/wishlist_id/:id`

###POST
`/users` create a new user, same for others

###PUT
You can edit what you want like `/users/:id/mail/:mail`, this is the same for all others

###DELETE
You can delete with `/users/:id/delete`, same for others too.

