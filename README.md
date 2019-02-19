# README
# gold_transfer
* don't forget rake db:seed

* http://localhost:3000/api/register This allows a new user to register
  example request
  post
  headers Content-Type: application/json
  body
  {
    "email": "gold@example.com", "password": "123456789", "password_confirmation": "123456789", "region": "th", "first_name": "Gold", "last_name": "Seller"
  }

* http://localhost:3000/api/users/sign_in Sign in for get token
  example request
  post
  headers Content-Type: application/json
  body
  {
    "api_user":	{
      "email": "gold@example.com", "password": "123456789"
    }
  }

* http://localhost:3000/api/transactions - This provides a listing of all the transactions in the DB
  example request
  get
  headers
  X-USER-EMAIL:gold@example.com
  X-USER-TOKEN:XXXXXXXXXXX

* http://localhost:3000/api/transactions/top_up - This allows a user to top up their cash balance
  example request
  post
  headers
  X-USER-EMAIL:gold@example.com
  X-USER-TOKEN:XXXXXXXXXXX
  Content-Type:application/json
  body
  {
    "amount": 1112
  }

* http://localhost:3000/api/transactions/buy - This allows the user to buy gold
  example request
  post
  headers
  X-USER-EMAIL:gold@example.com
  X-USER-TOKEN:XXXXXXXXXXX
  Content-Type:application/json
  body
  {
    "amount": 40,
    "asset": "gold"
  }

* http://localhost:3000/api/transactions/sell - This allows the user to sell gold
  example request
  post
  headers
  X-USER-EMAIL:gold@example.com
  X-USER-TOKEN:XXXXXXXXXXX
  Content-Type:application/json
  body
  {
    "amount": 40,
    "asset": "gold"
  }

* http://localhost:3000/api/transactions/withdraw - This allows the user to withdraw cash
  example request
  post
  headers
  X-USER-EMAIL:gold@example.com
  X-USER-TOKEN:XXXXXXXXXXX
  Content-Type:application/json
  body
  {
    "amount": 500
  }

* http://localhost:3000/api/balance This returns the current balance of gold andcash (and any other assets)
  example request
  get
  headers
  X-USER-EMAIL:gold@example.com
  X-USER-TOKEN:XXXXXXXXXXX
  Content-Type:application/json

* http://localhost:3000 For staffs sign in to do something about transactions