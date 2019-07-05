class Discord::Sync
  def self.start(args)
    Jobs.enqueue(:discord_sync_group_with_role, args)
  end

  def self.enqueue_next(args)
    Jobs.enqueue_at(1.days.from_now, :discord_sync_group_with_role, args)
  end
end
