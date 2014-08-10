class User < ActiveRecord::Base
  establish_connection 'legacy_%s' % Rails.env
  self.primary_key=:id
  INDEX_NAME='user-index'.freeze
  BATCH_SIZE=1000

  def uuid
    @uuid ||= '%du' % self.id
  end

  def to_hash
    {
      uuid: self.uuid,
      username: self.username,
      subtitle_count: self.subtitle_count,
      segment_count: self.segment_count
    }
  end

end