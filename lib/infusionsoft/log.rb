class ::Infusionsoft::Log
  def self.all
    [*PluginStore.new('infusionsoft').get('logs')]
  end

  def self.create(message)
    logs = self.all
    logs = logs.push({ message: message, completed_at: DateTime.now })
    PluginStore.new('infusionsoft').set('logs', logs)
  end

  def self.list
    self.all.sort_by { |h| h["completed_at"] }.reverse[0..50]
  end
end