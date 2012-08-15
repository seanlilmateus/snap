describe PacketActivatePlayer do
  behaves_like Packet
  before { @active_player_packet = PacketActivatePlayer.packetWithPeerID("Mattes") }
  
  it 'should be of type ActivatePlayer' do
    @active_player_packet.type.should.equal TheGame::SNAPPacketType::ActivatePlayer
  end
  
  it 'should have data of size 17' do
    @active_player_packet.data.length.should.equal 17
  end
  
  def peer_id(name)
     lambda do |obj| 
        count = Pointer.new(:char)
        obj.string_offset(TheGame::SNAPPacketType::PACKET_HEADER_SIZE, bytesRead:count) == name
        count[0].should.equal 7
     end
  end
  
  it 'data should have Mattes as peer_id' do
    @active_player_packet.data.should.be.a peer_id("Mattes")
  end
end

