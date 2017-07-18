require "active-campaign-rails/version"
require "active-campaign-rails/client"
require 'rest-client'

class ActiveCampaign

  # Makes the Client's methods available to an instance of the ActiveCampaign class
  include ActiveCampaign::Client

  attr_reader :api_endpoint, :api_key, :action_calls

  def initialize(args)

    # Parse args into instance_variable
    args.each do |k,v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end

    # Set default api_output to json if not set
    @api_output = 'json' if @api_output == nil

    @action_calls = generate_action_calls
  end


  def method_missing(api_action, *args, &block)

    # Generate api_url
    api_url = generate_api_url(api_action)

    # Check method for api_action given
    case @action_calls[api_action][:method]
    when 'get'

      # Generate API parameter from given argument
      api_params = (args.any?) ? args.first.map{|k,v| "#{k}=#{v}"}.join('&') : nil

      # Join API url and API parameters
      api_url = api_params ? "#{api_url}&#{api_params}" : api_url

      # Make a call to API server with GET method
      response = RestClient.get(api_url)

      # Return response from API server
      # Default to JSON
      return response.body

    when 'post'
# client = ActiveCampaign.new(api_endpoint: Settings.active_campaign.api_endpoint, api_key: Settings.active_campaign.api_key)
# client.connection_add({ connection: { service: 'foo', externalid: 1, name: 'foo', logoUrl: 'foo', linkUrl: 'foo' }})
# client.customer_add({ ecomCustomer: { connectionid: 4, externalid: 123, email: 'alice@example.com' }})
# client.contact_add({ contact: { email: 'test123@example.com' } })
      # API parameters for POST method
      api_params = args.first
      response = RestClient.post(api_url, api_params.to_json, { content_type: :json, accepnt: :json })

      # Return response from API server
      # Default to JSON
      return response.body
    when 'put'
      api_params = args.first.merge(api_key: @api_key)
      api_url = "#{@api_endpoint}#{@action_calls[api_action][:path]}".gsub(/:id/, api_params[:id].to_s)

      # Make a call to API server with DELETE method
      response = RestClient::Request.execute(method: :put, url: api_url, headers: { params: api_params })

      # Return response from API server
      # Default to JSON
      return response.body
    when 'delete'
#client.connection_delete(id: 3)
#client.customer_delete(id: 1)
      api_params = args.first.merge(api_key: @api_key)
      api_url = "#{@api_endpoint}#{@action_calls[api_action][:path]}".gsub(/:id/, api_params[:id].to_s)

      # Make a call to API server with DELETE method
      response = RestClient::Request.execute(method: :delete, url: api_url, headers: { params: api_params })

      # Return response from API server
      # Default to JSON
      return response.body
    end
  end

  private
    def generate_api_url(api_action)
      host = @api_endpoint
      path = @action_calls[api_action.to_sym][:path]

      "#{host}#{path}?api_key=#{@api_key}"
    end
end
