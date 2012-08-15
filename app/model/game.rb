class Game
  include TheGame::State
  
  attr_accessor :delegate
  def is_server?; @is_server; end
  
  def init
    super.tap {  @players = NSMutableDictionary.dictionaryWithCapacity(4) }
  end
  
  def dealloc
    NSLog("dealloc %@", self) if DEBUG
  end
  
  def startClientGameWithSession(session, playerName:name, server:peer_id)
    @is_server = false
    @session = session
    @session.available = false
    @session.delegate = self
    @session.setDataReceiveHandler(self, withContext:nil)
    
    @server_peer_id = peer_id
    @local_player_name = name
    @state = WaitingForSignIn
    @delegate.gameWaitingForServerReady(self)
  end
  
  def startServerGameWithSession(session, playerName:name, clients:clients)
    @is_server = true
    @session = session
    @session.available = false
    @session.delegate = self
    @session.setDataReceiveHandler(self, withContext:nil)

    
    @state = WaitingForSignIn
    @delegate.gameWaitingForServerReady(self)
    
    # create the player object for the server
    player = Player.alloc.init
    player.name = name
    player.peer_id = @session.peerID
    player.position = TheGame::PlayerPosition::Bottom

    @players[player.peer_id] = player
    
    clients.each_with_index do |peer_id, idx|
      player = Player.alloc.init
      player.peer_id = peer_id
      @players[player.peer_id] = player
      
      player.position = if idx.zero? then clients.count == 1 ? TheGame::PlayerPosition::Top : TheGame::PlayerPosition::Left
                        elsif idx == 1 then TheGame::PlayerPosition::Top
                        else TheGame::PlayerPosition::Right
                        end
    end
    
    packet = Packet.packetWithType(TheGame::SNAPPacketType::SignInRequest)
    send_packet_to_all_clients(packet)
  end
  
  def quit_with_reason(reason)
    @state = Quitting
    
    if reason == QuitReasonUserQuit
      packet = Packet.packetWithType(TheGame::SNAPPacketType::ServerQuit)
      send_packet_to_all_clients(packet)
    else
      packet = Packet.packetWithType(TheGame::SNAPPacketType::ClientQuit)
      send_packet_to_server(packet)
    end
    
    @session.disconnectFromAllPeers
    @session.delegate = nil
    @session = nil
    
    @delegate.game(self, didQuitWithReason:reason)
  end
  
  def client_received_packet(packet)
    case packet.type
    when TheGame::SNAPPacketType::SignInRequest
      if @state == WaitingForSignIn
        @state = WaitingForReady
        packet = PacketSignInResponse.packetWithPlayerName(@local_player_name)
        send_packet_to_server(packet)
      end
    when TheGame::SNAPPacketType::ServerReady
      if @state == WaitingForReady
        @players = packet.players
        change_relative_positions_of_players
        
        packet = Packet.packetWithType(TheGame::SNAPPacketType::ClientReady)
        send_packet_to_server(packet)
        begin_game
      end
    when TheGame::SNAPPacketType::OtherClientQuit
      clientDidDisconnect(packet.peer_id) unless @state == Quitting
    when TheGame::SNAPPacketType::ServerQuit
      self.quit_with_reason(QuitReasonServerQuit)
    when TheGame::SNAPPacketType::DealCards
      handle_deal_cards_packet(packet) if @state == Dealing
    when TheGame::SNAPPacketType::ActivatePlayer
      handle_active_player_packet(packet) if @state == Playing
    else
			NSLog("Client received unexpected packet: %@", packet)
    end
  end
  
  def handle_active_player_packet(packet)
    peer_id = packet.peer_id
    
    new_player = self.playerWithPeerID(peer_id)
    return if new_player.nil?
    
    @active_player_position = new_player.position
    self.activate_player_at_position(@active_player_position)
  end
  
  def handle_deal_cards_packet(packet)
    packet.cards.each do |key, value|
      player = self.playerWithPeerID(key)
      player.closed_cards.add_cards_from_array(value)
    end
    
    starting_player = playerWithPeerID(packet.starting_player_id)
    @active_player_position = starting_player.position
    
    response_packet = Packet.packetWithType(TheGame::SNAPPacketType::ClientDealtCards)
    send_packet_to_server(response_packet)
    
    @state = Playing
    
    @delegate.gameShouldDealCards(self, startingWithPlayer:starting_player)
  end
  
  def received_responses_from_all_prayers
    @players.map do |peer_id, player|
      return false unless player.received_response
    end
    true
  end
  
  
  def server_received_packet(packet, fromPlayer:player)
    NSLog("Packet Type: %@", packet.type) 
    case packet.type
    when TheGame::SNAPPacketType::SignInResponse
      if @state == WaitingForSignIn
        player.name = packet.player_name
        if received_responses_from_all_prayers
          @state = WaitingForReady
          packet = PacketServerReady.packetWithPlayers(@players)
          send_packet_to_all_clients(packet)
        end
      end
    when TheGame::SNAPPacketType::ClientReady
			NSLog("State: %d, received Responses: %d", @state, self.received_responses_from_all_prayers)
      if @state == WaitingForReady and self.received_responses_from_all_prayers
        NSLog("Beginning Game")
        begin_game
      end
    when TheGame::SNAPPacketType::ClientQuit
      clientDidDisconnect(player.peer_id)
    when TheGame::SNAPPacketType::ClientDealtCards
      if @state == Dealing and self.received_responses_from_all_prayers
        @state = Playing
      end
    else
			NSLog("Server received unexpected packet: %@", packet)
    end
  end
  
  def playerWithPeerID(peer_id)
    @players[peer_id]
  end
  
  def begin_game
    @state = Dealing
    @delegate.gameDidBegin(self)
    
    if self.is_server?
      self.pick_random_starting_player
      self.deal_cards
    end
  end
  
  def change_relative_positions_of_players
    return if self.is_server?
    my_player = self.playerWithPeerID(@session.peerID)
    diff = my_player.position
    my_player.position = TheGame::PlayerPosition::Bottom
    
    @players.reject { |key, player| player == my_player }
            .map    { |key, player| player.position = (player.position - diff) % 4 }
  end
  
  def player_at_position(position)
  	#NSAssert(position >= TheGame::PlayerPosition::Bottom && position <= TheGame::PlayerPosition::Right, "Invalid player position")
    @players.select { |key, player| player.position == position }.values.first
  end
  
  # NetWorking
  def send_packet_to_all_clients(packet)
    data_mode = GKSendDataReliable
    data = packet.data
    error = nil
    
    @players.map { |key, player| player.received_response = @session.peerID == player.peer_id }
    
    unless @session.sendDataToAllPeers(data, withDataMode:data_mode, error:error)
      NSLog("Error sending data to clients: %@", error.value)
    end
  end
  
  def send_packet_to_server(packet)
    data_mode = GKSendDataReliable
    data = packet.data
    error = nil
        
    unless @session.sendData(data, toPeers:[@server_peer_id], withDataMode:data_mode, error:error)
  		NSLog("Error sending data to server: %@", error.value)
    end
  end
  
  def clientDidDisconnect(peer_id)
    unless @state == Quitting
      player = playerWithPeerID(peer_id)
      unless player.nil?
        @players.delete(peer_id) { |el| NSLog("%@ not found", el) }
        unless @state == WaitingForSignIn
          # Tell the other clients that this one is now disconnected.
          if self.is_server?
            packet = PacketOtherClientQuit.packetWithPeerID(peer_id)
            send_packet_to_all_clients(packet)
          end
          @delegate.game(self, playerDidDisconnect:player)
        end
      end
    end
  end
  
  def pick_random_starting_player
    begin
      @starting_player_position = [0, 1, 2, 3].sample
    end while self.player_at_position(@starting_player_position).nil?
    @active_player_position = @starting_player_position
  end
  
  def deal_cards
    NSAssert(self.is_server?, "Must be server")
    NSAssert(@state == Dealing, "Wrong state")
    
    deck = Deck.alloc.init
    deck.shiffle
    while deck.remaining_cards > 0
      @starting_player_position.upto(@starting_player_position + 4) do |pos|
        player = self.player_at_position(pos % 4)
        if !player.nil? and deck.remaining_cards > 0
          card = deck.draw
          player.closed_cards.add_card_to_top(card)
        end
      end 
    end
    
    starting_player = self.active_player
    player_cards = NSMutableDictionary.dictionaryWithCapacity(4)
    @players.each_values { |plyr| player_cards[plyr.peer_id] = plyr.closed_cards.array }
    
    packet = PacketDealCards.packetWithCards(player_cards, startingWithPlayerPeerID:starting_player.peer_id)
    self.send_packet_to_all_clients(packet)
    @delegate.gameShouldDealCards(self, startingWithPlayer:starting_player)
  end
  
  def active_player
    self.player_at_position(@active_player_position)
  end
  
  def begin_round
    self.activate_player_at_position(@active_player_position)
  end
  
  def activate_player_at_position(pos)
    if self.is_server?
      peer_id = self.active_player.peer_id
      packet = PacketActivatePlayer.packetWithPeerID(peer_id)
      self.send_packet_to_all_clients(packet)
    end
    
    @delegate.game(self, didActivatePlayer: self.active_player)
  end
  
  # GKSessionDelegate
  def session(session, peer:peer_id, didChangeState:state)
    NSLog("Game: peer %@ changed state %@", peer_id, state) if DEBUG
    if state == GKPeerStateDisconnected
      if self.is_server?
        clientDidDisconnect(peer_id)
      elsif peer_id == @server_peer_id
        self.quit_with_reason(QuitReasonConnectionDropped)
      end
    end
  end
  
  def session(session, didReceiveConnectionRequestFromPeer:peer_id)
  	NSLog("Game: connection request from peer %@", peer_id)
  	session.denyConnectionFromPeer(peer_id)
  end
  
  def session(session, connectionWithPeerFailed:peer_id, withError:error)
    NSLog("Game: connection with peer %@ failed %@", peer_id, error) if DEBUG
  end
  
  def session(session, didFailWithError:error)
  	NSLog("Game: session failed %@", error) if DEBUG
    if error.domain == GKSessionErrorDomain
      self.quit_with_reason(QuitReasonConnectionDropped) unless @state == Quitting
    end
  end
  
  # GKSession Data Receive Handler
  def receiveData(data, fromPeer:peer_id, inSession:session, context:context)
  	NSLog("Game: receive data from peer: %@, data: %@, length: %@", peer_id, data, data.length) if DEBUG
    
    packet = Packet.packetWithData(data)
    if packet.nil?
      NSLog("Invalid packet: %@", data)
      return
    end
    
    player = self.playerWithPeerID(peer_id)
    player.received_response = true unless player.nil?
    
    if self.is_server?
      server_received_packet(packet, fromPlayer:player)
    else
      client_received_packet(packet)
    end
  end
end