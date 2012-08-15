class Packet
  include TheGame::SNAPPacketType
  attr_accessor :type
  
  def self.packetWithType(type)
    self.alloc.initWithType(type)
  end

  def self.packetWithData(data)
    def self.valid_data?(input_data)    
      if input_data.length < PACKET_HEADER_SIZE
        NSLog("Error: Packet too small") 
        true
      end
      if input_data.int32_offset(0) != "SNAP".unpack('H*')[0].to_i(16)
         NSLog("Error: Packet has invalid header")
         true 
      end
    end
    
    return nil if valid_data?(data)
    
    packet_num = data.int32_offset(4)
    packet_type = data.int16_offset(8)
    
    packet = case packet_type
             when TheGame::SNAPPacketType::SignInRequest,
                  TheGame::SNAPPacketType::ClientReady,
                  TheGame::SNAPPacketType::ClientDealtCards,
                  TheGame::SNAPPacketType::ServerQuit,
                  TheGame::SNAPPacketType::ClientQuit      then Packet.packetWithType(packet_type)
             when TheGame::SNAPPacketType::SignInResponse  then PacketSignInResponse.packetWithData(data)
             when TheGame::SNAPPacketType::ServerReady     then PacketServerReady.packetWithData(data)
             when TheGame::SNAPPacketType::OtherClientQuit then PacketOtherClientQuit.packetWithData(data)
             when TheGame::SNAPPacketType::DealCards       then PacketDealCards.packetWithData(data)
             when TheGame::SNAPPacketType::ActivatePlayer  then PacketActivatePlayer.packetWithData(data)
             else
                NSLog("Invalid Packet %@", input_data)
          		  NSLog("Error: Packet has invalid type")
                nil
             end
  end
  
  def initWithType(type)
    init.tap { @type = type }
  end
  
  def data
    data = NSMutableData.alloc.initWithCapacity(100)
    data.append_int32('SNAP'.unpack('H*')[0].to_i(16))
    data.append_int32(0x0)
    data.append_int16(@type)
    
    add_playload_to_data(data)
    data
  end
  
  def add_playload_to_data(data)
    # base class does nothing
  end
  
  def description
    "type = #{@type}, #{super}"
  end
  
  def addCards(cards, toPayload:data)
    cards.each do |key, array|
      data.append_string(key)
      data.append_int8(array.count)
      array.each do |card|
        data.append_int8(card.suit)
        data.append_int8(card.value)
      end
    end
  end
  
  def self.cardsFromData(data, atOffset:offset)
    count = Pointer.new(:char)
    cards = NSMutableDictionary.dictionaryWithCapacity(4)
    
    while(offset < data.length)
      peer_id = data.string_offset(offset, bytesRead:count)
      offset += count[0]
      
      number_of_cards = data.int8_offset(offset)
      offset += 1
      
      cards_array = NSMutableArray.arrayWithCapacity(number_of_cards)
      number_of_cards.times do |t|
        suit = data.int8_offset(offset)
        offset += 1
        
        value = data.int8_offset(offset)
        offset += 1        
        cards_array << Card.alloc.initWithSuit(suit, value:value)
      end
      cards[peer_id] = cards_array
    end
    cards
  end
end
