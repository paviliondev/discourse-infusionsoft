class ::Infusionsoft::Contact
  def self.update_group(email, group_name, action)
    if user = User.find_by_email(email)
      if group = Group.find_by(name: group_name)
        group.send(action, user)
      end
    end
  end
end
