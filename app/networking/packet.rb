class Packet
  include Game::SNAPPacketType
  attr_accessor :type
  
  def self.packetWithType(type)
    self.alloc.initWithType(type)
  end

  def self.packetWithData(data)
    def self.valid_data?(input_data)    
      if input_data.length < PACKET_HEADER_SIZE
        NSLog("Error: Packet too small") ; true
      end
    
      ### must be checked for sure
      if input_data.int32_offset(0) != "SNAP".unpack('H*')[0].to_i(16)
         NSLog("Error: Packet has invalid header") ; true 
      end
    end
    
    return nil if valid_data?(data)
    
    packet_num = data.int32_offset(4)
    packet_type = data.int16_offset(8)
    
    packet = case packet_type 
              when Game::SNAPPacketType::SignInRequest  then Packet.packetWithType(packet_type)
              when Game::SNAPPacketType::SignInResponse then PacketSignInResponse.packetWithData(data)
              else 
          			NSLog("Error: Packet has invalid type")
                nil
              end
  end
  
  def initWithType(type)
    init.tap { @type = type }
  end
  
  def data
    data = NSMutableData.alloc.initWithCapacity(100)
    data.append_int32("SNAP".unpack('H*')[0].to_i(16))
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
end
