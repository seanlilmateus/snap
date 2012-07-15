class PacketSignInResponse < Packet
  attr_accessor :player_name
  
  def self.packetWithData(data)
    count = nil
    player_name = data.string_at_offset(PACKET_HEADER_SIZE, bytesRead:count)
    self.packetWithPlayerName(player_name)
  end
  
  def self.packetWithPlayerName(player_name)
    self.alloc.initWithPlayerName(player_name)
  end
  
  def initWithPlayerName(player_name)
    initWithType(SignInResponse).tap { @player_name = player_name }      
  end
  
  def add_playload_to_data(data)
    data.append_string(data)
  end
end