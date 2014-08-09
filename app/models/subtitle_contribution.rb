class SubtitleContribution < ActiveRecord::Base
  establish_connection 'legacy_%s' % Rails.env
end