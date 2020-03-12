module Jobs
  class InfusionsoftTagGroupSync < ::Jobs::Scheduled
    every 1.day

    def execute(args)
      tr_tag_emails = Infusionsoft::Subscription.tr_tag_emails
      tag_group_map = Infusionsoft::Helper.tag_group_map

      tag_group_map.keys.each do |tag_id|
        tag_contacts = Infusionsoft::Subscription.request('GET', "tags/#{tag_id}/contacts")
        group_name = "#{tag_group_map[tag_id]}_AL"
        tr_group_name = "#{tag_group_map[tag_id]}_TR"

        group = Infusionsoft::Helper.find_or_create_group(group_name)
        tr_group = Infusionsoft::Helper.find_or_create_group(tr_group_name)

        [group, tr_group].each do |group|
          group.group_users.each do |gu|
            gu.update_columns(primary_group_id: nil) if gu.user.primary_group_id == gu.group_id
            gu.destroy
          end
        end

        tag_contacts['contacts'].each do |c|
          email = c['contact']['email']
          user = Infusionsoft::Helper.find_or_create_user(email)

          if tr_tag_emails.include?(email)
            tr_group.send('add', user)
          else
            group.send('add', user)
          end
        end
      end

      Infusionsoft::Log.create("tag group sync completed")
    end
  end
end
