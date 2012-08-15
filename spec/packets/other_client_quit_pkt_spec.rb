describe PacketOtherClientQuit do
  behaves_like Packet
  
  before { @other_client_packet = PacketOtherClientQuit.packetWithPeerID("Mattes") }
  
  it 'should be of type OtherClientQuit' do
    @other_client_packet.type.should.equal TheGame::SNAPPacketType::OtherClientQuit
  end
  
  def peer_id(name)
     lambda do |obj| 
        count = Pointer.new(:char)
        obj.string_offset(TheGame::SNAPPacketType::PACKET_HEADER_SIZE, bytesRead:count) == name
        count[0].should.equal 7
     end
  end
  
  it 'data should have Mattes as peer_id' do
    @other_client_packet.data.should.be.a peer_id("Mattes")
  end
  
  it 'should have data of size 17' do
    @other_client_packet.data.length.should.equal 17
  end
end