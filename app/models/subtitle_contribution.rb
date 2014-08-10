class SubtitleContribution < ActiveRecord::Base
  establish_connection 'legacy_%s' % Rails.env
  self.primary_key=:id
  def user_uuid
    '%du' % self.user_id
  end

  def channel_uuid
    '%dc' % self.channel_id
  end
end