class Role < ActiveRecord::Base
  establish_connection 'legacy_%s' % Rails.env
end