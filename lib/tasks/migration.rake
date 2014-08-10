task :import => :environment do |t, args|
  user_index = 'user-index'
  channel_index = 'channel-index'
  language_index = 'language-index'
  country_index = 'country-index'
  indexes = [user_index, channel_index, language_index, country_index]
  countries = YAML.load(File.read(Rails.root.join('config', 'countries.yml')))
  languages = YAML.load(File.read(Rails.root.join('config', 'languages.yml')))

  # Remove all existing data
  $neo.execute_script('g.V.sideEffect{g.removeVertex(it)}.iterate()')
  # Reset indexes
  existing_indexes = $neo.list_node_indexes
  indexes.each do |index|
    $neo.drop_node_index(index) if existing_indexes[index]
    $neo.create_node_index(index) # 'g.createIndex("user-index", Vertex.class)'
  end

  country_nodes_by_code = {}
  countries.each_pair do |code, attributes|
    country_nodes_by_code[code] = $neo.create_unique_node(country_index, 'code', code, {name: attributes['name']['en']})
  end

  language_nodes_by_code = {}
  languages.each_pair do |code, attributes|
    language_nodes_by_code[code] = $neo.create_unique_node(language_index, 'code', code, {name: attributes['name']['en']})
  end

  user_ids = Set.new
  channel_ids = Set.new

  roles = []
  #Role.find_each do |role|
  Role.limit(1000).each do |role|
    roles << role
    user_ids << role.user_id
    channel_ids << role.channel_id
  end

  contributions = []
  #SubtitleContribution.find_each do |contribution|
  SubtitleContribution.limit(1000).each do |contribution|
    contributions << contributions
    user_ids << contribution.user_id
    channel_ids << contribution.channel_id
  end

  user_nodes_by_uuid = {}
  user_ids.to_a.in_groups_of(User::BATCH_SIZE) do |ids|
    User.where(id: ids).each do |user|
      user_nodes_by_uuid[user.uuid] = $neo.create_unique_node(User::INDEX_NAME, 'uuid', user.uuid, user.to_hash)
      next if user_nodes_by_uuid[user.uuid].nil?
      next if country_nodes_by_code[user.last_country_code].nil?
      next if user.last_country_code == 'rd' || user.last_country_code.nil?
      $neo.create_relationship('comes from', user_nodes_by_uuid[user.uuid], country_nodes_by_code[user.last_country_code])
    end
  end

  channel_nodes_by_uuid = {}
  channel_ids.to_a.in_groups_of(Channel::BATCH_SIZE) do |ids|
    Channel.where(id: ids).each do |channel|
      channel_nodes_by_uuid[channel.uuid] = $neo.create_unique_node(Channel::INDEX_NAME, 'uuid', channel.uuid, channel.to_hash)
      next if channel_nodes_by_uuid[channel.uuid].nil?
      next if country_nodes_by_code[channel.country].nil?
      next if channel.country == 'rd' || channel.country.nil?
      $neo.create_relationship('comes from', channel_nodes_by_uuid[channel.uuid], country_nodes_by_code[channel.country])
    end
  end

  roles.each do |role|
    user_node = user_nodes_by_uuid[role.user_uuid]
    channel_node = channel_nodes_by_uuid[role.channel_uuid]

    next if user_node.nil? || channel_node.nil?
    # user -> channel
    count = SubtitleContribution.where(user_id: role.user_id, channel_id: role.channel_id).select('sum(count) AS total_count').sum(:count)
    relation = $neo.create_relationship('contributes to', user_node, channel_node)
    $neo.set_relationship_properties(relation, {role: role.name, count: count})

    # user -> language
    language_node = language_nodes_by_code[role.language_code]
    if language_node
      $neo.create_relationship('contributes in', user_node, language_node)
    end
  end
end