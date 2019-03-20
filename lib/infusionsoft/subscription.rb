require 'excon'

class Infusionsoft::Subscription
  def self.get(event)
    PluginStore.get('infusionsoft', event) || {}
  end

  def self.set(event, key, status)
    PluginStore.set('infusionsoft', event,
      key: key,
      status: status
    )
  end

  def self.remove(event, key)
    response = Excon.delete(
      "https://api.infusionsoft.com/crm/rest/v1/hooks/#{key}",
      :headers => {
        "Authorization" => "Bearer #{Infusionsoft::Authorization.access_token[:token]}",
      }
    )

    if response.status.to_i == 204
      current = self.get(event)
      if current && current['key'] == 'key'
        PluginStore.remove('infusionsoft', event)
      end
    end
  end

  def self.request(type, path, body = nil)
    connection = Excon.new(
      "https://api.infusionsoft.com/crm/rest/v1/#{path}",
      :headers => {
        "Authorization" => "Bearer #{Infusionsoft::Authorization.access_token[:token]}",
        "Accept" => "application/json, */*",
        "Content-Type" => "application/json"
      }
    )

    if body
      connection.body = body.to_json
    end

    response = connection.request(:method => type)

    JSON.parse(response.body)
  end

  def self.create(event)
    data = request('POST', "hooks",
      eventKey: event,
      hookUrl: (Rails.env.development? ? Infusionsoft::NGROK_URL : Discourse.base_url) + "/infusionsoft/subscription/hook"
    )

    self.handle_response(event, data)
  end

  def self.verify(event, key)
    data = request('POST', "hooks/#{key}/verify")
    self.handle_response(event, data)
  end

  def self.handle_response(event, data)
    self.set(event, data['key'], data['status'])
  end

  def self.list
    response = Excon.get(
      "https://api.infusionsoft.com/crm/rest/v1/hooks",
      :headers => {
        "Authorization" => "Bearer #{Infusionsoft::Authorization.access_token[:token]}",
      }
    )
    JSON.parse(response.body)
  end
end
