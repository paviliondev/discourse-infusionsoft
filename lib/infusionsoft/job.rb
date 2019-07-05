class ::Infusionsoft::Job
  def self.find_or_create_group(name)
    Group.find_by(name: name) || Group.create(name: name)
  end

  def self.find_or_create_user(email)
    name = email.split("@").first
    user = nil

    User.transaction do
      user = User.find_by_email(email)

      if user.nil? && SiteSetting.enable_staged_users
        raise EmailNotAllowed unless EmailValidator.allowed?(email)

        username = UserNameSuggester.sanitize_username(name) if name.present?

        begin
          user = User.create!(
            email: email,
            username: UserNameSuggester.suggest(username.presence || email),
            name: name.presence || User.suggest_name(email),
            staged: true
          )
        rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
          user = nil
        end
      end
    end

    user
  end

  def self.log_completion(name)
    jobs = self.list
    jobs = jobs.push({ name: name, completed_at: DateTime.now })
    PluginStore.set('infusionsoft', 'jobs', jobs)
  end

  def self.list
    PluginStore.get('infusionsoft', 'jobs')
  end
end
