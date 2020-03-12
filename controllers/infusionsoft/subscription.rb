class Infusionsoft::SubscriptionController < ::ApplicationController
  skip_before_action :check_xhr,
                     :preload_json,
                     :redirect_to_login_if_required,
                     :verify_authenticity_token

  def hook
    Infusionsoft::Job.log_completion("Request received: #{params.keys}")
    
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
            contact_tag_ids = contact['tag_ids']
            has_tr_tag = contact_tag_ids.include?(Infusionsoft::TRADING_ROOM_TAG)
            contact_tag_ids = contact_tag_ids.select { |tid| tid != Infusionsoft::TRADING_ROOM_TAG }
            
            tr_tag_changed = tag_id == Infusionsoft::TRADING_ROOM_TAG
            email = contact['email_addresses'].map { |obj| obj['email'] }.first
            action = event[1] == "applied" ? "add" : "remove"
            
            if tr_tag_changed
              contact_tag_ids.each do |tag_id|
                al_action = action == "add" ? "remove" : "add"
                update_group(email, "#{Infusionsoft::TAG_GROUP_MAP[tag_id]}_AL", al_action)
                update_group(email, "#{Infusionsoft::TAG_GROUP_MAP[tag_id]}_TR", action)
              end
            else 
              group_type = has_tr_tag ? "TR" : "AL"
              update_group(email, "#{Infusionsoft::TAG_GROUP_MAP[tag_id]}_#{group_type}", action)              
            end
          end
        end
      end
    end
  end
  
  def update_group(email, group_name, action)
    if user = User.find_by_email(email)
      if group = Group.find_by(name: group_name)
        Infusionsoft::Job.log_completion("#{action} #{user.username} - group '#{group_name}'")
        group.send(action, user)
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
