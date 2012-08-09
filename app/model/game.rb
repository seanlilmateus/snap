class Game
  include Game::State
  
  attr_accessor :delegate
  def is_server?; @is_server; end
  
  def init
    super
    @players = NSMutableDictionary.dictionaryWithCapacity(4)
    self
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
    player.position = Game::PlayerPosition::Bottom

    @players[player.peer_id] = player
    
    clients.each_with_index do |peer_id, idx|
      player = Player.alloc.init
      player.peer_id = peer_id
      @players[player.peer_id] = player
      
      player.position = if idx.zero? then clients.count == 1 ? Game::PlayerPosition::Top : Game::PlayerPosition::Left
                        elsif idx == 1 then Game::PlayerPosition::Top
                        else Game::PlayerPosition::Right
                        end
    end
    
    packet = Packet.packetWithType(Game::SNAPPacketType::SignInRequest)
    send_packet_to_all_clients(packet)
  end
  
  def quit_with_reason(reason)
    @state = Quitting
    
    if reason == QuitReasonUserQuit
      packet = Packet.packetWithType(Game::SNAPPacketType::ServerQuit)
      send_packet_to_all_clients(packet)
    else
      packet = Packet.packetWithType(Game::SNAPPacketType::ClientQuit)
      send_packet_to_server(packet)
    end
    
    @session.disconnectFromAllPeers
    @session.delegate = nil
    @session = nil
    
    @delegate.game(self, didQuitWithReason:reason)
  end
  
  def client_received_packet(packet)
    case packet.type
    when Game::SNAPPacketType::SignInRequest
      if @state == WaitingForSignIn
        @state = WaitingForReady
        packet = PacketSignInResponse.packetWithPlayerName(@local_player_name)
        send_packet_to_server(packet)
      end
    when Game::SNAPPacketType::ServerReady
      if @state == WaitingForReady
        @players = packet.players
        change_relative_positions_of_players
        
        packet = Packet.packetWithType(Game::SNAPPacketType::ClientReady)
        send_packet_to_server(packet)
        begin_game
      end
    when Game::SNAPPacketType::OtherClientQuit
      clientDidDisconnect(packet.peer_id) unless @state == Quitting
    when Game::SNAPPacketType::ServerQuit
      self.quit_with_reason(QuitReasonServerQuit)
    else
			NSLog("Client received unexpected packet: %@", packet)
    end
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
    when Game::SNAPPacketType::SignInResponse
      if @state == WaitingForSignIn
        player.name = packet.player_name
        if received_responses_from_all_prayers
          @state = WaitingForReady
          packet = PacketServerReady.packetWithPlayers(@players)
          send_packet_to_all_clients(packet)
        end
      end
    when Game::SNAPPacketType::ClientReady
			NSLog("State: %d, received Responses: %d", @state, self.received_responses_from_all_prayers)
      if @state == WaitingForReady and self.received_responses_from_all_prayers
        NSLog("Beginning Game")
        begin_game
      end
    when Game::SNAPPacketType::ClientQuit
      clientDidDisconnect(player.peer_id)
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
  end
  
  def change_relative_positions_of_players
    return if self.is_server?
    my_player = self.playerWithPeerID(@session.peerID)
    diff = my_player.position
    my_player.position = Game::PlayerPosition::Bottom
    
    @players.reject { |key, player| player == my_player }
            .map    { |key, player| player.position = (player.position - diff) % 4 }
  end
  
  def player_at_position(position)
  	#NSAssert(position >= Game::PlayerPosition::Bottom && position <= Game::PlayerPosition::Right, "Invalid player position")
    @players.select { |key, player| player.position == position }.values.first
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
end