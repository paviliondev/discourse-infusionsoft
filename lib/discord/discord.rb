require 'excon'

module Discord
  def self.request(type, path, body = nil)

    puts "URL: https://discordapp.com/api/v6#{path}"

    connection = Excon.new(
      "https://discordapp.com/api/v6#{path}",
      :headers => {
        "Authorization" => "Bot #{SiteSetting.discord_bot_token}",
        "Accept" => "application/json, */*",
        "Content-Type" => "application/json",
        "User-Agent" => "Development"
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
end
