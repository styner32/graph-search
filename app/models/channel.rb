class Channel < ActiveRecord::Base
  establish_connection 'legacy_%s' % Rails.env
  self.primary_key=:id
  INDEX_NAME='user-index'.freeze
  BATCH_SIZE=1000

  def uuid
    @uuid ||= '%dc' % self.id
  end

  def to_hash
    {
      uuid: self.uuid
    }
  end
end