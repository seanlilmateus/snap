describe PacketServerReady do
  behaves_like Packet
  
  before do
    players = {
      "first" => Player.alloc.init.tap do |plr| 
        plr.peer_id = "Mattes"
        plr.name = "Mattes" 
        plr.position = TheGame::PlayerPosition::Bottom
      end
    }
    @server_ready_packet = PacketServerReady.packetWithPlayers(players)
  end
  
  it 'should be of type ServerReady' do
    @server_ready_packet.type.should.equal TheGame::SNAPPacketType::ServerReady
  end
  
  it 'should have data of size 26' do
    @server_ready_packet.data.length.should.equal 26
  end
end
