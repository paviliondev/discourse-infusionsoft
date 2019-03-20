module Jobs
  class InfusionsoftTagGroupSync < Jobs::Base
    def execute(args)
      tr_tag_contacts = Infusionsoft::Subscription.request('GET', "tags/#{Infusionsoft::TRADING_ROOM_TAG}/contacts")
      tr_tag_emails = tr_tag_contacts['contacts'].map { |c| c['contact']['email'] }

      Infusionsoft::TAG_GROUP_MAP.keys.each do |tag_id|
        tag_contacts = Infusionsoft::Subscription.request('GET', "tags/#{tag_id}/contacts")
        group_name = "#{Infusionsoft::TAG_GROUP_MAP[tag_id]}_AL"
        tr_group_name = "#{Infusionsoft::TAG_GROUP_MAP[tag_id]}_TR"

        tag_contacts['contacts'].each do |c|
          email = c['contact']['email']

          Infusionsoft::Contact.update_group(email, group_name, 'add')

          if tr_tag_emails.include?(email)
            Infusionsoft::Contact.update_group(email, tr_group_name, 'add')
          end
        end
      end
    end
  end
end
