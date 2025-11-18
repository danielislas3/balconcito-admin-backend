module Loyverse
  class Client
    BASE_URL = ENV.fetch('LOYVERSE_API_URL', 'https://api.loyverse.com/v1.0')
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

    # GET /shifts
    def get_shifts(params = {})
      get('/shifts', params)
    end

    # GET /shifts/:id
    def get_shift(shift_id)
      get("/shifts/#{shift_id}")
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
      require 'net/http'
      require 'uri'
      require 'json'

      # Construir URL
      url = if method == :get && params_or_body.any?
              query = URI.encode_www_form(params_or_body)
              "#{BASE_URL}#{endpoint}?#{query}"
            else
              "#{BASE_URL}#{endpoint}"
            end

      uri = URI(url)

      # Configurar HTTP
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      # En desarrollo, deshabilitar verificación SSL estricta
      http.verify_mode = Rails.env.development? ? OpenSSL::SSL::VERIFY_NONE : OpenSSL::SSL::VERIFY_PEER
      http.read_timeout = 30
      http.open_timeout = 30

      # Crear request
      request = case method
                when :get
                  Net::HTTP::Get.new(uri)
                when :post
                  req = Net::HTTP::Post.new(uri)
                  req.body = params_or_body.to_json
                  req['Content-Type'] = 'application/json'
                  req
                when :delete
                  Net::HTTP::Delete.new(uri)
                end

      # Agregar autenticación
      request['Authorization'] = "Bearer #{api_token}"

      # Ejecutar request
      response = http.request(request)

      handle_response(response)
    rescue => e
      Rails.logger.error("Loyverse API error: #{e.class} - #{e.message}")
      raise
    end

    def handle_response(response)
      case response.code.to_i
      when 200, 201
        JSON.parse(response.body)
      when 401
        raise 'Invalid API token'
      when 429
        raise 'Rate limit exceeded (60 requests/minute)'
      when 404
        raise 'Resource not found'
      else
        raise "API error: #{response.code} - #{response.body}"
      end
    end
  end
end
