class PacketActivatePlayer < Packet
  attr_accessor :peer_id
  
  def self.packetWithPeerID(peer_id)
    self.alloc.initWithPeerID(peer_id)
  end
  
  def initWithPeerID(peer_id)
    initWithType(ActivatePlayer).tap { @peer_id = peer_id }
  end
  
  def self.packetWithData(data)
    count = Pointer.new(:char)
    peer_id = data.string_offset(PACKET_HEADER_SIZE, bytesRead:count)
    self.class.packetWithPeerID(peer_id)
  end
  
  def add_playload_to_data(data)
    data.append_string(@peer_id)
  end
end