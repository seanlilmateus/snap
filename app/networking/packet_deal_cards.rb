class PacketDealCards < Packet
  attr_accessor :cards, :starting_peer_id
  def self.packetWithCards(cards, startingWithPlayerPeerID:starting_peer_id)
    self.alloc.initWithCards(cards, startingWithPlayerPeerID:starting_peer_id)
  end
  
  def self.packetWithData(data)
    offset = PACKET_HEADER_SIZE
    count = Pointer.new(:char)
    
    starting_peer_id = data.string_offset(offset, bytesRead:count)
    offset += count[0]
    
    cards = self.class.cardsFromData(data, atOffset:offset)
    self.class.packetWithCards(cards, startingWithPlayerPeerID:starting_peer_id)
  end
  
  def initWithCards(cards, startingWithPlayerPeerID:starting_peer_id)
    initWithType(DealCards).tap do
      @cards = cards
      @starting_peer_id = starting_peer_id
    end
  end
  
  def add_playload_to_data(data)
    data.append_string(@starting_peer_id)
    self.addCards(@cards, toPayload:data)
  end
end