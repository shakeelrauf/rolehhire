require 'rails_helper'

describe 'Trades', type: :request do
  describe 'POST /trades' do
    let(:shares) { 30 }
    let(:trade_type) { 'buy' }
    
    let(:trade_params) do
      {
        trade_type: trade_type,
        user_id: 23,
        symbol: 'ABX',
        shares: shares,
        price: 134,
        timestamp: 1531522701000
      }
    end

    before do
      post '/trades', params: trade_params
    end

    context 'when "shares" is more than 100' do
      let(:shares) { 101 }

      it 'returns 400 status code' do
        expect(response.status).to eq(400)
      end

      it 'does not add a trade to the database' do
        get '/trades'
        fail('Cannot access GET /trades') unless response.status == 200

        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'when "shares" is less than 0' do
      let(:shares) { -1 }

      it 'returns 400 status code' do
        expect(response.status).to eq(400)
      end

      it 'does not add a trade to the database' do
        get '/trades'
        fail('Cannot access GET /trades') unless response.status == 200

        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'when "trade_type" is invalid' do
      let(:trade_type) { 'invalid' }

      it 'returns 400 status code' do
        expect(response.status).to eq(400)
      end

      it 'does not add a trade to the database' do
        get '/trades'
        fail('Cannot access GET /trades') unless response.status == 200

        expect(JSON.parse(response.body)).to eq([])
      end
    end

    context 'when incoming parameters are correct' do  
      it 'returns status code 201' do
        expect(response.status).to eq(201)
      end

      it 'adds a trade to the database' do
        get '/trades'
        fail('Cannot access GET /trades') unless response.status == 200

        expected = [
          {
            id: 1,
            trade_type: 'buy',
            user_id: 23,
            symbol: 'ABX',
            shares: 30,
            price: 134,
            timestamp: 1531522701000
          }.stringify_keys
        ]

        expect(JSON.parse(response.body)).to eq(expected)
      end

      it 'returns JSON of a created trade' do
        expected = {
          id: 1,
          trade_type: 'buy',
          user_id: 23,
          symbol: 'ABX',
          shares: 30,
          price: 134,
          timestamp: 1531522701000
        }.stringify_keys

        expect(JSON.parse(response.body)).to eq(expected)
      end
    end
  end

  describe 'GET /trades/:id' do
    context 'when trade by given ID exists' do
      let(:trade_params) do
        {
          trade_type: 'sell',
          user_id: 100,
          symbol: 'USD',
          shares: 20,
          price: 100,
          timestamp: 1531411663408
        }
      end

      let(:trade) do
        post '/trades', params: trade_params
        fail('Cannot create a trade') unless response.status == 201
        JSON.parse(response.body)
      end

      before do
        get "/trades/#{trade['id']}"
      end

      it 'returns 200 status code' do
        expect(response.status).to eq(200)
      end

      it 'returns JSON of a corresponding trade' do
        expected = {
          id: trade['id'],
          trade_type: 'sell',
          user_id: 100,
          symbol: 'USD',
          shares: 20,
          price: 100,
          timestamp: 1531411663408
        }.stringify_keys

        expect(JSON.parse(response.body)).to eq(expected)
      end
    end

    context 'when trade by given ID does not exist' do
      before do
        get '/trades/999'
      end

      it 'returns 404 status code' do
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'GET /trades' do
    it 'returns status 200' do
      get '/trades'
      expect(response.status).to eq(200)
    end

    context 'when there are trades in the system' do
      let(:trade_params) do
        [
          {
            trade_type: 'sell',
            user_id: 120,
            symbol: 'EUR',
            shares: 15,
            price: 15,
            timestamp: 1541711664408
          },
          {
            trade_type: 'buy',
            user_id: 201,
            symbol: 'RUB',
            shares: 16,
            price: 150,
            timestamp: 1541711644408
          } 
        ]
      end

      before do
        trade_params.each do |params|
          post '/trades', params: params
          fail('Cannot create a trade') unless response.status == 201
        end
      end

      it 'returns trades collection ordered by ID' do
        get '/trades'

        expected = trade_params.each.with_index(1) do |params, index|
          params['id'] = index
        end.map(&:stringify_keys)

        expect(JSON.parse(response.body)).to eq(expected)
      end

      context 'when "user_id" is provided in the request' do
        it 'returns trades of a given user only' do
          get '/trades', params: {user_id: 201}

          expected = [
            {
              id: 2,
              trade_type: 'buy',
              user_id: 201,
              symbol: 'RUB',
              shares: 16,
              price: 150,
              timestamp: 1541711644408
            }.stringify_keys
          ]

          expect(JSON.parse(response.body)).to eq(expected)
        end
      end

      context 'when "trade_type" is provided in the request' do
        it 'returns trades of a given type only' do
          get '/trades', params: {trade_type: :sell}

          expected = [
            {
              id: 1,
              trade_type: 'sell',
              user_id: 120,
              symbol: 'EUR',
              shares: 15,
              price: 15,
              timestamp: 1541711664408
            }.stringify_keys
          ]

          expect(JSON.parse(response.body)).to eq(expected)
        end
      end
    end

    context 'when there are no trades in the system' do
      it 'returns empty array JSON' do
        get '/trades'
        expect(JSON.parse(response.body)).to eq([])
      end
    end
  end

  describe 'DELETE /trades/:id' do
    let(:trade) do
      post '/trades', params: {
        trade_type: 'buy',
        user_id: 201,
        symbol: 'RUB',
        shares: 10,
        price: 150,
        timestamp: 1541711644408
      }
      fail('Cannot create a trade') unless response.status == 201

      JSON.parse(response.body)
    end

    before do
      delete "/trades/#{trade['id']}"
    end

    it 'returns status 405' do
      expect(response.status).to eq(405)
    end
  end

  describe 'PATCH /trades/:id' do
    let(:trade) do
      post '/trades', params: {
        trade_type: 'buy',
        user_id: 201,
        symbol: 'RUB',
        shares: 10,
        price: 150,
        timestamp: 1541711644408
      }
      fail('Cannot create a trade') unless response.status == 201
      
      JSON.parse(response.body)
    end

    before do
      patch "/trades/#{trade['id']}"
    end

    it 'returns status 405' do
      expect(response.status).to eq(405)
    end
  end

  describe 'PUT /trades/:id' do
    let(:trade) do
      post '/trades', params: {
        trade_type: 'buy',
        user_id: 201,
        symbol: 'RUB',
        shares: 10,
        price: 150,
        timestamp: 1541711644408
      }
      fail('Cannot create a trade') unless response.status == 201
      
      JSON.parse(response.body)
    end

    before do
      put "/trades/#{trade['id']}"
    end

    it 'returns status 405' do
      expect(response.status).to eq(405)
    end
  end
end
