describe PacketDealCards do
  behaves_like Packet
  before do 
    player = Player.alloc.init
    player.peer_id = "Mattes"
    player.name = "Mattes" 
    player.position = TheGame::PlayerPosition::Bottom

    deck = Deck.alloc.init
    deck.setup_cards


    player.closed_cards.add_card_to_top(deck.draw)
    
    cards = {  player.peer_id => player.closed_cards.array }
    @deal_cards_packet = PacketDealCards.packetWithCards(cards, startingWithPlayerPeerID:player.peer_id)
  end
  
  it 'should be of type DealCards' do
    @deal_cards_packet.type.should.equal TheGame::SNAPPacketType::DealCards
  end
  
  def peer_id(name)
     lambda do |obj| 
        count = Pointer.new(:char)
        obj.string_offset(TheGame::SNAPPacketType::PACKET_HEADER_SIZE, bytesRead:count) == name
        count[0].should.equal 7
     end
  end
  
  it 'data should have Mattes as peer_id' do
    @deal_cards_packet.data.should.be.a peer_id("Mattes")
  end
  
  it 'should have data of size 27' do
    @deal_cards_packet.data.length.should.equal 27
  end
end