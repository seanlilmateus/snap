class MatchClient

  ClientStateIdle = 0
  ClientStateSearchingForServers = 1
  ClientStateConnecting = 2
  ClientStateConnected = 3

  attr_accessor :availables_servers, :session, :session_id, :client_state, :delegate
  
  def init
    super.tap { @client_state = ClientStateIdle }
  end

  def startSearchingForServersWithSessionID(an_id)
    if @client_state == ClientStateIdle
      @client_state = ClientStateSearchingForServers
      @availables_servers = NSMutableArray.arrayWithCapacity(10)

      @session = GKSession.alloc.initWithSessionID(an_id, displayName:nil, sessionMode:GKSessionModeClient).tap do |gks|
        gks.delegate = self
        gks.available = true
      end
    end
  end
  
  def connectToServerWithPeerID(peer_id)
    @client_state == ClientStateConnecting
    @server_peer_id = peer_id
    @session.connectToPeer(peer_id, withTimeout:@session.disconnectTimeout)
  end

  # GKSessionDelegate
  def session(a_session, peer:peer_id, didChangeState:state)
    NSLog("#{self.class}: peer #{peer_id} changed state #{state}")
    case state
      when GKPeerStateAvailable                   # The client has discovered a new server.
        if @client_state == ClientStateSearchingForServers
          unless @availables_servers.include?(peer_id)
            @availables_servers << peer_id
            @delegate.matchClient(self, serverBecameUnavailable:peer_id)
          end
        end
      when GKPeerStateUnavailable                 # The client sees that a server goes away.
        if @client_state == ClientStateSearchingForServers
          if @availables_servers.include?(peer_id)
            @availables_servers.delete(peer_id)
            @delegate.matchClient(self, serverBecameUnavailable:peer_id)
          end
        end
        # Is this the server we're currently trying to connect with?
        self.disconnectFromServer if @client_state == ClientStateConnecting and peer_id == @server_peer_id
      when GKPeerStateConnected                   # You're now connected to the server.
        @client_state = ClientStateConnected if @client_state == ClientStateConnecting
      when GKPeerStateDisconnected                # You're now no longer connected to the server.
        self.disconnectFromServer if @client_state == ClientStateConnected
      when GKPeerStateConnecting then nil
    end
  end
  
  def session(a_session, didReceiveConnectionRequestFromPeer:peer_id)
    NSLog("#{self.class}: connection request from peer #{peer_id}")
  end
  
  def session(a_session, connectionWithPeerFailed:peer_id, withError:error)
    NSLog("#{self.class}: connection with peer #{peer_id} failed #{error}")
    self.disconnectFromServer
  end
  
  def session(a_session, didFailWithError:error)
    NSLog("#{self.class}: Session failed #{error}")
    if error.domain == GKSessionErrorDomain
      if error.code == GKSessionCannotEnableError
        @delegate.matchClientNoNetwork(self)
        self.disconnectFromServer
      end
    end
  end

  def available_server_count
    @availables_servers.count
  end

  def peerIDForAvailableServerAtIndex(idx)
    @availables_servers[idx]
  end

  def displayNameForPeerID(peer_id)
    @session.displayNameForPeer(peer_id)
  end

  def disconnect_from_server
    @client_state = ClientStateIdle
    @session.disconnectFromAllPeers
    @session.available = false
    @session.delegate = nil
    @session = nil

    @availables_servers = []
    @delegate.matchClient(self, didDisconnectFromServer:@server_peer_id)
    @server_peer_id = nil
  end
end
