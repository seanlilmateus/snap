module GameState
  WaitingForSignIn = 0
  WaitingForReady = 1
  Dealing = 2
  Playing = 3
  GameOver = 4
  Quitting = 5
end

class Game
  include GameState
  attr_accessor :delegate
  
  def is_server?; @is_server; end
  def init
    super.tap { @players = NSMutableDictionary.dictionaryWithCapacity(4) }
  end
  
  def dealloc
    NSLog("dealloc %@", self) if DEBUG
  end
  
  def startClientGameWithSession(session, playerName:name, server:peer_id)
    @is_server = false
    @session = session.tap do |sess|
      sess.available = false
      sess.delegate = self
      sess.setDataReceiveHandler(self, withContext:nil)
    end
    
    @server_peer_id = peer_id
    @local_player_name = name
    @state = WaitingForSignIn
    @delegate.gameWaitingForServerReady(self)
  end
  
  def startServerGameWithSession(session, playerName:name, clients:clients)
    @is_server = true
    @session = session.tap do |sess|
      sess.available = false
      sess.delegate = self
      sess.setDataReceiveHandler(self, withContext:nil)
    end
    
    @state = WaitingForSignIn
    @delegate.gameWaitingForServerReady(self)
    
    # create the player object for the server
    Player.alloc.init.tap do |plyr|
      plyr.name = name
      plyr.peer_id = @session.peer_id
      plyr.position = PlayerPosition::Bottom
    end
    @players[player.peer_id] = player
    
    clients.each_with_index do |peer_id, idx|
      player = Player.alloc.init
      player.peer_id = peer_id
      @players[player.peer_id] = player
      
      player.position = if idx.zero? then clients.count == 1 ? PlayerPosition::Top : PlayerPosition::Left
                        elsif idx == 1 then PlayerPosition::Top
                        else PlayerPosition::Right
                        end
    end
    packet = Packet.packetWithType(SNAPPacketType::SignInRequest)
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
    when SNAPPacketType::SignInRequest
      if @state == WaitingForSignIn
        @state = WaitingForReady
        packet = PacketSignInResponse.packetWithPlayerName(@local_player_name)
        self.send_packet_to_server(packet)
      end
    else
			NSLog("Client received unexpected packet: %@", packet)
    end
  end
  
  def server_received_packet(packet, fromPlayer:player)
    case packet.type
    when SNAPPacketType::SignInResponse
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
  	NSLog("Game: receive data from peer: %@, data: %@, length: %d", peer_id, data, data.length) if DEBUG
    
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