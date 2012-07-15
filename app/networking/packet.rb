module SNAPPacketType
  PACKET_HEADER_SIZE = 10
  SignInRequest = 0x64      # server to client
  SignInResponse = 0x65     # client to server
  
  ServerReady = 0x66        # server to client
  ClientReady = 0x67        # client to server
  
  DealCards = 0x68          # server to client
  ClientDealtCards = 0x69   # client to server
  
  ActivatePlayer = 0x6A     # server to client
  ClientTurnedCard = 0x6B   # client to server
  
  PlayerShouldSnap = 0x6C   # client to server
  PlayerCalledSnap = 0x6D   # server to client
  
  OtherClientQuit = 0x6E    # server to client
  ServerQuit = 0x70         # server to client
  ClientQuit = 0x71         # server to client
end

class Packet
  include SNAPPacketType
  attr_accessor :type
  
  def self.packetWithType(type)
    self.alloc.initWithType(type)
  end
  
  def self.packetWithData(data)
    def invalid_data?(input_data)
      if input_data.length < PACKET_HEADER_SIZE
        NSLog("Error: Packet too small") ; true
      end
      ### must be checked for sure
      if input_data.int32_offset(0) != 'SNAP'
        NSLog("Error: Packet has invalid header") ; true 
      end
    end
    return nil if invalid_data?(data)
    
    packet_num = data.int32_offset(4)
    packet_type = data.int16_offset(8)
    
    packet = case packet_type 
              when SNAPPacketType::SignInRequest then Packet.packetWithType(packet_type)
              when SNAPPacketType::SignInResponse then PacketSignInResponse.packetWithData(data)
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
    
    self.add_playload_to_data(data)
    data
  end
  
  def add_playload_to_data(data)
    # base class does nothing
  end
  
  def description
    "type = #{@type}, #{super}"
  end
end
