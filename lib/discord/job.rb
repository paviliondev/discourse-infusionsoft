class ::Discord::Job
  def self.log_completion(name)
    jobs = self.list
    jobs = jobs.push({ name: name, completed_at: DateTime.now })
    PluginStore.set('discord', 'jobs', jobs)
  end

  def self.list
    [*PluginStore.get('discord', 'jobs')]
  end
end
