class Infusionsoft::SubscriptionController < ::ApplicationController
  skip_before_action :check_xhr,
                     :preload_json,
                     :redirect_to_login_if_required,
                     :verify_authenticity_token

  def hook
    if params[:verification_key]
      response.headers['X-Hook-Secret'] = request.headers["X-Hook-Secret"]
      render status: 200, json: {
        verification_key: params[:verification_key]
      }.to_json
    else
      event = params[:event_key].split('.')

      if event[0] == "contactGroup"
        updates = params[:object_keys]

        updates.each do |data|
          tag_id = data[:tag_id].to_i

          if Infusionsoft::TAG_GROUP_MAP.key?(tag_id)
            contact_id = data[:contact_details].first[:id]
            contact = Infusionsoft::Subscription.request('GET', "contacts/#{contact_id}")
            action = event[1] == "applied" ? "add" : "remove"
            email = contact['email_addresses'].map { |obj| obj['email'] }.first
            group_name = "#{Infusionsoft::TAG_GROUP_MAP[tag_id]}_AL"

            Infusionsoft::Contact.update_group(email, group_name, action)

            if contact['tag_ids'].include?(Infusionsoft::TRADING_ROOM_TAG)
              group_name = "#{Infusionsoft::TAG_GROUP_MAP[tag_id]}_TR"

              Infusionsoft::Contact.update_group(email, group_name, action)
            end
          end
        end
      end
    end
  end

  def remove
    Infusionsoft::Subscription.remove(params[:event], params[:key])
    render json: success_json.merge(subscriptions: Infusionsoft::Subscription.list)
  end

  def create
    Infusionsoft::Subscription.create(params[:event])
    render json: success_json.merge(subscriptions: Infusionsoft::Subscription.list)
  end

  def verify
    Infusionsoft::Subscription.verify(params[:event], params[:key])
    render json: success_json.merge(subscriptions: Infusionsoft::Subscription.list)
  end
end
