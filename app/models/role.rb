class Role < ActiveRecord::Base
  establish_connection 'legacy_%s' % Rails.env
  self.primary_key=:id
  def name
    case self.position
    when self.position & 32
      role_name = 'manager'
    when self.position & 16
      role_name = 'moderator'
    when self.position & 8
      role_name = 'segmenter'
    when self.position & 4
      role_name =  'subtitler'
    end

    return role_name
  end

  def user_uuid
    '%du' % self.user_id
  end

  def channel_uuid
    '%dc' % self.channel_id
  end
end