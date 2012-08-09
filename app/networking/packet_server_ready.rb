class PacketServerReady < Packet
  attr_accessor :players  
  def self.packetWithPlayers(players)
    self.alloc.initWithPlayers(players)
  end
  
  def initWithPlayers(players)
    initWithType(ServerReady).tap { @players = players }
  end
  
  def self.packetWithData(data)
    players = NSMutableDictionary.dictionaryWithCapacity(4)
    
    offset = PACKET_HEADER_SIZE
    count = Pointer.new(:char)
    number_of_players = data.int8_offset(offset)
    offset += 1
    
    number_of_players.times do |t|
      peer_id = data.string_offset(offset, bytesRead:count)
      offset += count[0] #value
      NSLog("Pointer methods: %@", count)
      
      name = data.string_offset(offset, bytesRead:count)
      offset += count[0] # value
      
      position = data.int8_offset(offset)
      offset += 1
      
      Player.alloc.init.tap do |player|
        player.peer_id = peer_id
        player.name = name
        player.position = position
        players[player.peer_id] = player
      end
    end
    self.packetWithPlayers(players)
  end
  
  def add_playload_to_data(data)
    data.append_int8(@players.count)
    
    @players.each do |key, player|
      data.append_string(player.peer_id)
      data.append_string(player.name)
      data.append_int8(player.position)
    end
  end
end