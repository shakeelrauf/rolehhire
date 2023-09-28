# Ruby on Rails: Stock Trades API

## Project Specifications

**Read-Only Files**
- spec/*

**Environment**  

- Ruby version: 3.2.2
- Rails version: 7.0.0
- Default Port: 8000

**Commands**
- run: 
```bash
bin/bundle exec rails server --binding 0.0.0.0 --port 8000
```
- install: 
```bash
bin/bundle install
```
- test: 
```bash
RAILS_ENV=test bin/rails db:migrate && RAILS_ENV=test bin/bundle exec rspec
```
    
## Question description

In this challenge, your task is to implement a simple REST API to manage a collection of stock trades.

Each trade has the following structure:

- `id`: The unique ID of the trade. (Integer)
- `trade_type`: The type of the trade, either 'buy' or 'sell'. (String)
- `user_id`: The unique user ID. (Integer)
- `symbol`: Currency symbol of the trade. (String)
- `shares`: The total number of shares traded. (Integer)
- `price`: The price of one share of stock at the time of the trade. (Integer)
- `timestamp`: The epoch time of the stock trade in milliseconds. (Integer)


### Example of a trade data JSON object:
```
{
    "id": 1,
    "trade_type": "buy",
    "user_id": 23,
    "symbol": "ABX",
    "shares": 30,
    "price": 134,
    "timestamp": 1531522701000
}
```

## Requirements:

The REST service must expose the `/trades` endpoint, which allows for managing the collection of trade records in the following way:

`POST /trades`:

- creates a new trade
- expects a JSON trade object without an id property as a body payload
- validates the following conditions:
  - `shares` is in a range of [0, 100]
  - `trade_type` is either `sell` or `buy`
- if any of the above validations fail, returns status code 400
- otherwise, adds the given trade object to the collection of trades and assigns a unique integer id to it. The first created trade must have id 1, the second one 2, and so on.
- the response code is 201, and the response body is the JSON of created trade object

`GET /trades`:

- returns a JSON of the collection of all trades, ordered by id in increasing order
- returns response code 200
- accepts optional query parameter `user_id`. When `user_id` is provided, it returns trades of a specified user only.
- accepts optional query parameter `trade_type`. When `trade_type` is provided, it returns trades of a specified type only.

`GET /trades/<id>`:

- returns a JSON of a trade with the given id
- if the matching trade exists, the response code is 200 and the response body is the matching trade object
- if there is no trade with the given id in the collection, the response code is 404

`DELETE`, `PUT`, `PATCH` request to `/trades/<id>`:

- the response code is 405 because the API does not allow deleting or modifying trades for any id value
