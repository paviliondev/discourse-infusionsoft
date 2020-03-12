require 'excon'

class Infusionsoft::Subscription
  def self.get(event)
    PluginStore.new('infusionsoft').get(event) || {}
  end

  def self.set(event, key, status)
    PluginStore.new('infusionsoft').set(event,
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
        PluginStore.new('infusionsoft').remove(event)
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

    params = {
      method: type
    }

    if body
      params[:body] = body.to_json
    end

    response = connection.request(params)

    JSON.parse(response.body)
  end

  def self.create(event)
    data = request('POST', "hooks",
      eventKey: event,
      hookUrl: (Rails.env.development? ? Infusionsoft::Helper.local_url : Discourse.base_url) + "/infusionsoft/subscription/hook"
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
  
  def self.tr_tag_emails
    tr_tag_contacts = Infusionsoft::Subscription.request('GET', "tags/#{SiteSetting.infusionsoft_trading_room_tag_id}/contacts")
    tr_tag_contacts['contacts'].map { |c| c['contact']['email'] }
  end
end
