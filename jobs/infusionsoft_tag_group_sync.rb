module Jobs
  class InfusionsoftTagGroupSync < Jobs::Scheduled
    every 1.day

    def execute(args)
      tr_tag_contacts = Infusionsoft::Subscription.request('GET', "tags/#{Infusionsoft::TRADING_ROOM_TAG}/contacts")
      tr_tag_emails = tr_tag_contacts['contacts'].map { |c| c['contact']['email'] }

      Infusionsoft::TAG_GROUP_MAP.keys.each do |tag_id|
        tag_contacts = Infusionsoft::Subscription.request('GET', "tags/#{tag_id}/contacts")
        group_name = "#{Infusionsoft::TAG_GROUP_MAP[tag_id]}_AL"
        tr_group_name = "#{Infusionsoft::TAG_GROUP_MAP[tag_id]}_TR"

        group = Infusionsoft::Job.find_or_create_group(group_name)
        tr_group = Infusionsoft::Job.find_or_create_group(tr_group_name)

        [group, tr_group].each do |group|
          group.group_users.each do |gu|
            gu.update_columns(primary_group_id: nil) if gu.user.primary_group_id == gu.group_id
            gu.destroy
          end
        end

        tag_contacts['contacts'].each do |c|
          email = c['contact']['email']
          user = Infusionsoft::Job.find_or_create_user(email)
          group.send('add', user)

          if tr_tag_emails.include?(email)
            tr_group.send('add', user)
          end
        end
      end

      Infusionsoft::Job.log_completion('sync_tag_groups')
    end
  end
end
