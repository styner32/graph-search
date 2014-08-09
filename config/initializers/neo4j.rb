require 'neography'

Neography.configure do |config|
  config.protocol             = 'http://'
  config.server               = 'localhost'
  config.port                 = 7474
  config.directory            = ''
  config.cypher_path          = '/cypher'
  config.gremlin_path         = '/ext/GremlinPlugin/graphdb/execute_script'
  config.log_file             = 'neography.log'
  config.log_enabled          = false
  config.slow_log_threshold   = 0
  config.max_threads          = 20
  config.authentication       = nil
  config.username             = nil
  config.password             = nil
  config.parser               = MultiJsonParser
  config.http_send_timeout    = 1200
  config.http_receive_timeout = 1200
end

$neo = Neography::Rest.new