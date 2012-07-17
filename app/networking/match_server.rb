class MatchServer
  include Game::ServerState
  attr_accessor :max_clients, :connected_clients, :session, :session_id, :delegate

  def init
    super.tap { @server_state = ServerStateIdle }
  end


  def startAcceptingConnectionsForSessionID(id)
    if @server_state = ServerStateIdle
      @server_state = ServerStateAcceptingConnections
      @connected_clients = NSMutableArray.arrayWithCapacity(@max_clients)
      @session = GKSession.alloc.initWithSessionID(id,displayName:nil, sessionMode:GKSessionModeServer).tap do |gks|
        gks.delegate = self
        gks.available = true
      end
    end
  end
  
  # GKSessionDelegate
  def session(a_session, peer:peer_id, didChangeState:state)
    NSLog("#{self.class}: peer #{peer_id} changed state #{state}")
    case state
      when GKPeerStateAvailable, GKPeerStateUnavailable then nil
      when GKPeerStateConnected                       # A new client has connected to the server.
        if @server_state == ServerStateAcceptingConnections
          unless @connected_clients.include?(peer_id)
            @connected_clients << peer_id
            @delegate.matchServer(self, clientDidConnect:peer_id)
          end
        end
      when GKPeerStateDisconnected                    # A client has disconnected from the server.
        unless @server_state == ServerStateIdle
          if @connected_clients.include?(peer_id)
            @connected_clients.delete(peer_id)
            @delegate.matchServer(self, clientDidDisconnect:peer_id)
          end
        end
      when GKPeerStateConnecting then nil
    end
  end
  
  def session(a_session, didReceiveConnectionRequestFromPeer:peer_id)
    NSLog("#{self.class}: connection request from peer #{peer_id}")
    if @server_state == ServerStateAcceptingConnections and self.connected_clients_count < @max_clients
      error = nil
      if @session.acceptConnectionFromPeer(peer_id, error:error)
        NSLog("MatchServer: Connection accepted from peer %@", peer_id);
      else
        NSLog("MatchServer: Error accepting connection from peer %@, %@", peer_id, error.value)
      end
    else  # not accepting connections or too many clients
      @session.denyConnectionFromPeer(peer_id)
    end
  end
  
  def session(a_session, connectionWithPeerFailed:peer_id, withError:error)
    NSLog("#{self.class}: connection with peer #{peer_id} failed #{error.description}")
  end
  
  def session(a_session, didFailWithError:error)
    NSLog("#{self.class}: Session failed #{error}")
    if error.domain == GKSessionErrorDomain
      if error.code == GKSessionCannotEnableError
        @delegate.matchServerNoNetwork(self)
        self.end_session
      end
    end
  end


  def connected_clients_count
    @connected_clients.count
  end

  def peerIDForConnectedClientAtIndex(idx)
    @connected_clients[idx]
  end

  def displayNameForPeerID(peer_id)
    @session.displayNameForPeer(peer_id)
  end

  def stopAcceptingConnections
    @server_state = ServerStateIgnoringNewConnections
    @session.available = false  
  end

  def end_session
    @server_state = ServerStateIdle
    @session.disconnectFromAllPeers
    @session.available = false
    @session = nil

    @connected_clients = nil

    @delegate.matchServerSessionDidEnd(self)
  end
end
