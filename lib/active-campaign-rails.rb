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

  def method_missing(api_action, id = nil, options = {})
# client = ActiveCampaign.new(api_endpoint: Settings.active_campaign.api_endpoint, api_key: Settings.active_campaign.api_key)
# client.contact_list
# client.contact_add(nil, { email: 'test123@example.com' }) # TODO: Remove requirement here for nil
# client.contact_get(6)
# client.contact_delete(6)

    # Generate api_url
    api_url = generate_api_url(api_action)
    api_url = "#{@api_endpoint}#{@action_calls[api_action][:path]}".gsub(/:id/, id.to_s) if id.present?

    payload = nil
    if options.has_key?(:payload) && @action_calls[api_action].has_key?(:api_action)
      payload = options[:payload]
    elsif options.any? && !@action_calls[api_action].has_key?(:api_action)
      payload = { @action_calls[api_action][:data_key] => options }.to_json
    end

    response = RestClient::Request.execute(
      method: @action_calls[api_action][:method],
      url: api_url,
      headers: {
        params: {
          api_key: @api_key
        }
      },
      payload: payload
    )

    return JSON.parse(response.body)
  end

  private
    def generate_api_url(api_action)
      if @action_calls[api_action.to_sym].has_key?(:api_action)
        host = @api_endpoint.gsub(/api\/3/, '')
        path = "admin/api.php?api_key=#{@api_key}&api_action=#{@action_calls[api_action.to_sym][:api_action]}&api_output=json"
      else
        host = @api_endpoint
        path = @action_calls[api_action.to_sym][:path]

      end

      "#{host}#{path}"
    end
end
