shared Packet do
  before { @packet = Packet.packetWithType(TheGame::SNAPPacketType::SignInRequest) }
  
  it 'should have a type between Sign In Request and Client Quit' do
    @packet.type.should.be.close TheGame::SNAPPacketType::SignInRequest, TheGame::SNAPPacketType::ClientQuit
  end
  
  it 'should have a SNAP header' do
    @packet.data.int32_offset(0).should.equal "SNAP".unpack('H*')[0].to_i(16)
  end
end
