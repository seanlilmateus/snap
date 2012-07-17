class PacketSignInResponse < Packet
  attr_accessor :player_name
  
  def self.packetWithData(data)
    count = Pointer.new(:object)
    name = data.string_offset(PACKET_HEADER_SIZE, bytesRead:count)
    self.packetWithPlayerName(name)
  end
  
  def self.packetWithPlayerName(name)
    self.alloc.initWithPlayerName(name)
  end
  
  def initWithPlayerName(name)
    initWithType(SignInResponse).tap { @player_name = name }
  end
  
  def add_playload_to_data(data)
    data.append_string(@player_name)
  end
end
