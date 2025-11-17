module Loyverse
  class Client
    BASE_URL = 'https://api.loyverse.com/v1.0'
    RATE_LIMIT = 60 # requests per minute

    attr_reader :api_token

    def initialize(api_token = nil)
      @api_token = api_token || LoyverseConfig.instance.api_token
      raise ArgumentError, 'API token not configured' if @api_token.blank?
    end

    # GET /receipts
    def get_receipts(params = {})
      get('/receipts', params)
    end

    # GET /receipts/:id
    def get_receipt(receipt_id)
      get("/receipts/#{receipt_id}")
    end

    # GET /payment_types
    def get_payment_types
      get('/payment_types')
    end

    # GET /stores
    def get_stores
      get('/stores')
    end

    # GET /employees
    def get_employees
      get('/employees')
    end

    # GET /items
    def get_items(params = {})
      get('/items', params)
    end

    # POST /webhooks
    def create_webhook(url, events)
      post('/webhooks', { url: url, events: events })
    end

    # GET /webhooks
    def get_webhooks
      get('/webhooks')
    end

    # DELETE /webhooks/:id
    def delete_webhook(webhook_id)
      delete("/webhooks/#{webhook_id}")
    end

    private

    def get(endpoint, params = {})
      request(:get, endpoint, params)
    end

    def post(endpoint, body = {})
      request(:post, endpoint, body)
    end

    def delete(endpoint)
      request(:delete, endpoint)
    end

    def request(method, endpoint, params_or_body = {})
      url = "#{BASE_URL}#{endpoint}"

      response = case method
                 when :get
                   HTTP.auth("Bearer #{api_token}")
                       .get(url, params: params_or_body)
                 when :post
                   HTTP.auth("Bearer #{api_token}")
                       .headers('Content-Type' => 'application/json')
                       .post(url, json: params_or_body)
                 when :delete
                   HTTP.auth("Bearer #{api_token}")
                       .delete(url)
                 end

      handle_response(response)
    rescue => e
      Rails.logger.error("Loyverse API error: #{e.message}")
      raise
    end

    def handle_response(response)
      case response.status
      when 200, 201
        JSON.parse(response.body)
      when 401
        raise 'Invalid API token'
      when 429
        raise 'Rate limit exceeded (60 requests/minute)'
      when 404
        raise 'Resource not found'
      else
        raise "API error: #{response.status} - #{response.body}"
      end
    end
  end
end
