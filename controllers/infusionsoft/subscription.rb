class Infusionsoft::SubscriptionController < ::ApplicationController
  skip_before_action :check_xhr,
                     :preload_json,
                     :redirect_to_login_if_required,
                     :verify_authenticity_token

  def hook
    if params[:verification_key]
      Infusionsoft::Log.create("web hook verification request received")
      
      response.headers['X-Hook-Secret'] = request.headers["X-Hook-Secret"]
      
      render status: 200, json: { verification_key: params[:verification_key] }.to_json
    else
      event = params[:event_key].split('.')
      
      Infusionsoft::Log.create("web hook post request received for #{params[:event_key]}")

      if event[0] == "contactGroup"
        updates = params[:object_keys]
        apply_updates(updates)
      end
      
      render plain: "[\"SUCCESS\"]", status: 200 
    end
  end
  
  def apply_updates(updates)
    updates.each do |data|
      tag_id = data[:tag_id].to_i
      tag_group_map = Infusionsoft::Helper.tag_group_map
      trading_room_tag_id = SiteSetting.infusionsoft_trading_room_tag_id.to_i

      if tag_group_map.key?(tag_id)
        contact_id = data[:contact_details].first[:id]
        contact = Infusionsoft::Subscription.request('GET', "contacts/#{contact_id}")
        contact_tag_ids = contact['tag_ids']
        has_tr_tag = contact_tag_ids.include?(trading_room_tag_id)
        contact_tag_ids = contact_tag_ids.select { |tid| tid != trading_room_tag_id }
        
        tr_tag_changed = tag_id == trading_room_tag_id
        email = contact['email_addresses'].map { |obj| obj['email'] }.first
        action = event[1] == "applied" ? "add" : "remove"
        
        if tr_tag_changed
          contact_tag_ids.each do |tag_id|
            al_action = action == "add" ? "remove" : "add"
            update_group(email, "#{tag_group_map[tag_id]}_AL", al_action)
            update_group(email, "#{tag_group_map[tag_id]}_TR", action)
          end
        else 
          group_type = has_tr_tag ? "TR" : "AL"
          update_group(email, "#{tag_group_map[tag_id]}_#{group_type}", action)              
        end
      end
    end
  end
  
  def update_group(email, group_name, action)
    if user = User.find_by_email(email)
      if group = Group.find_by(name: group_name)
        Infusionsoft::Log.create("#{action} #{user.username} - group '#{group_name}'")
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
