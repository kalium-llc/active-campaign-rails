class ActiveCampaign
  module Client
    # For more information visit http://www.activecampaign.com/api/overview.php
    def generate_action_calls
      # API V3 here
      api_list = {
        connection: 'connections',
        customer: 'ecomCustomers',
        order: 'ecomOrders',
        contact: 'contacts'
      }.inject({}) do |api_list, routes|
        (method_key, api_route) = routes
        api_list["#{method_key}_list".to_sym] = { method: 'get', path: "/#{api_route}" }
        api_list["#{method_key}_add".to_sym] = { method: 'post', path: "/#{api_route}", data_key: api_route.gsub(/s$/, '').to_sym }
        api_list["#{method_key}_delete".to_sym] = { method: 'delete', path: "/#{api_route}/:id" }
        api_list["#{method_key}_edit".to_sym] = { method: 'put', path: "/#{api_route}/:id" }
        api_list["#{method_key}_get".to_sym] = { method: 'get', path: "/#{api_route}/:id" }

        api_list
      end

      # OLD API
      api_list[:contact_tag_add] = { method: 'post', api_action: 'contact_tag_add' }
      api_list[:contact_view_email] = { method: 'post', api_action: 'contact_view_email' }

      api_list
    end
  end
end
