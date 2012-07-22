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
  
  def quit_game_with_reason(reason)
    @state = Quitting
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
    else
			NSLog("Client received unexpected packet: %@", packet)
    end
  end
  
  def server_received_packet(packet, fromPlayer:player)
    NSLog("Packet Type: %@", packet.type) 
    case packet.type
    when Game::SNAPPacketType::SignInResponse
      if @state == WaitingForSignIn
        player.name = packet.player_name
        NSLog("server received sign in from client '%@'", player.name)
      end
    else
			NSLog("Server received unexpected packet: %@", packet)
    end
  end
  
  def player_with_peer_id(peer_id)
    @players[peer_id]
  end
  
  # GKSessionDelegate
  def session(session, peer:peer_id, didChangeState:state)
    NSLog("Game: peer %@ changed state %@", peer_id, state) if DEBUG
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
  end
  
  # GKSession Data Receive Handler
  def receiveData(data, fromPeer:peer_id, inSession:session, context:context)
  	NSLog("Game: receive data from peer: %@, data: %@, length: %@", peer_id, data, data.length) if DEBUG
    
    packet = Packet.packetWithData(data)
    if packet.nil?
      NSLog("Invalid packet: %@", data)
      return
    end
    
    player = self.player_with_peer_id(peer_id)
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
end