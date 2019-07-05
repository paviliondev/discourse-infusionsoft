module Jobs
  class DiscordSyncGroupWithRole < Jobs::Base
    def execute(args)
      group = Group.find_by(name: args[:group])
      guild = Discord.request('GET', "/guilds/#{SiteSetting.discord_guild_id}")
      role = guild["roles"].select { |role| role['name'] == args[:role] }.first
      guild_members = Discord.request('GET', "/guilds/#{SiteSetting.discord_guild_id}/members")

      role_users = guild_members.select { |gm| gm['roles'].find { |role| role['name'] == args[:role] } }
      synced_users = [*Oauth2UserInfo.find_by(provider: 'discord')]
      group_user_ids = group.users.pluck(:id)

      verified_user_ids = synced_users.select { |su| group_user_ids.include?(su['user_id']) }.map(&:uid)
      add_user_ids = verified_user_ids.select { |vuid| !role_users.find { |ru| ru['id'] == vuid } }
      remove_user_ids = role_users.select { |ru| !verified_user_ids.include?(ru['id']) }

      puts "USER IDS: #{add_user_ids}; #{remove_user_ids}"

      add_user_ids.each do |user_id|
        result = Discord.request('PUT', "/guilds/#{SiteSetting.discord_guild_id}/members/#{user_id}/roles/#{role['id']}")
        puts "ADD USER IDS RESULT: #{result.inspect}"
      end

      remove_user_ids.each do |user_id|
        Discord.request('DELETE', "/guilds/#{SiteSetting.discord_guild_id}/members/#{user_id}/roles/#{role['id']}")
        puts "REMOVE USER ID RESULT: #{remove_user_ids.inspect}"
      end

      Discord::Sync.enqueue_next(args)

      Discord::Job.log_completion('sync_group_with_role')
    end
  end
end
