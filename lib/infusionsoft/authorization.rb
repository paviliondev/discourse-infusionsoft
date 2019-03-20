require 'excon'

class Infusionsoft::Authorization
  def self.access_token
    PluginStore.get('infusionsoft', 'access_token') || {}
  end

  def self.set_access_token(data)
    PluginStore.set('infusionsoft', 'access_token', data)
  end

  def self.refresh_token
    PluginStore.get('infusionsoft', 'refresh_token')
  end

  def self.set_refresh_token(token)
    PluginStore.set('infusionsoft', 'refresh_token', token)
  end

  def self.code
    PluginStore.get('infusionsoft', 'code')
  end

  def self.set_code(code)
    PluginStore.set('infusionsoft', 'code', code)
  end

  def self.get_access_token
    body = {
      client_id: SiteSetting.infusionsoft_client_id,
      client_secret: SiteSetting.infusionsoft_client_secret,
      code: Infusionsoft::Authorization.code,
      grant_type: 'authorization_code',
      redirect_uri: (Rails.env.development? ? Infusionsoft::NGROK_URL : Discourse.base_url) + '/infusionsoft/authorization/callback'
    }

    result = Excon.post(
      "https://api.infusionsoft.com/token",
      :headers => {
        "Content-Type" => "application/x-www-form-urlencoded"
      },
      :body => URI.encode_www_form(body)
    )

    self.handle_token_result(result)
  end

  def self.refresh_access_token
    body = {
      grant_type: 'refresh_token',
      refresh_token: Infusionsoft::Authorization.refresh_token
    }

    authorization_string = SiteSetting.infusionsoft_client_id + ':' + SiteSetting.infusionsoft_client_secret

    result = Excon.post(
      "https://api.infusionsoft.com/token",
      :headers => {
        "Content-Type" => "application/x-www-form-urlencoded",
        "Authorization" => "Basic #{Base64.strict_encode64(authorization_string)}"
      },
      :body => URI.encode_www_form(body)
    )

    self.handle_token_result(result)
  end

  def self.handle_token_result(result)
    data = JSON.parse(result.body)
    return false if (data['error'])

    token = data['access_token']
    expires_at = Time.now + data['expires_in'].seconds
    refresh_at = expires_at.to_time - 2.hours

    Jobs.enqueue_at(refresh_at, :refresh_infusionsoft_access_token)

    Infusionsoft::Authorization.set_access_token(
      token: token,
      expires_at: expires_at,
      refresh_at: refresh_at
    )

    Infusionsoft::Authorization.set_refresh_token(data['refresh_token'])
  end

  def self.authorized
    Infusionsoft::Authorization.access_token[:token] &&
    Infusionsoft::Authorization.access_token[:expires_at].to_datetime > Time.now
  end
end
