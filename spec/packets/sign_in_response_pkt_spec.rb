describe PacketSignInResponse do
  behaves_like Packet
  
  before { @sign_packet = PacketSignInResponse.packetWithPlayerName("Mattes") }
  
  it 'should be of type SignInRequest' do
    @sign_packet.type.should.equal TheGame::SNAPPacketType::SignInResponse
  end
  
  it 'should have a player called Mattes' do
    @sign_packet.player_name.should.match(/Mattes/)
  end
    
  it 'should have data of size 17' do
    @sign_packet.data.length.should.equal 17
  end
end