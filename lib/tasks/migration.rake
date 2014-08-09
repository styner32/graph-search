task :import => :environment do |t, args|
  #Remove all existing data
  $neo.execute_script('g.V.sideEffect{g.removeVertex(it)}.iterate();')
  Role.limit(10).each do |role|
    user_id = '%du' % role.user_id
    case role.position
    when role.position & 32
      role_name = 'manager'
    when role.position & 16
      role_name = 'moderator'
    when role.position & 8
      role_name = 'segmenter'
    when role.position & 4
      role_name =  'subtitler'
    end

    $neo.execute_script('g.addVertex("%s", [role: "%s"])' % [user_id, role_name])
    puts $neo.execute_script('g.V')
  end
end