class MatchServer
  attr_accessor :max_clients, :connected_clients, :session, :session_id

  def startAcceptingConnectionsForSessionID(id)
    @connected_clients = []
    @session = GKSession.alloc.initWithSessionID(id,displayName:nil, sessionMode:GKSessionModeServer).tap do |gks|
      gks.delegate = self
      gks.available = true
    end
  end
  
  # GKSessionDelegate
  def session(a_session, peer:peer_id, didChangeState:state)
    NSLog("#{self.class}: peer #{peer_id} changed state #{state}")
  end
  
  def session(a_session, didReceiveConnectionRequestFromPeer:peer_id)
    NSLog("#{self.class}: connection request from peer #{peer_id}")
  end
  
  def session(a_session, connectionWithPeerFailed:peer_id, withError:error)
    NSLog("#{self.class}: connection with peer #{peer_id} failed #{error}")
  end
  
  def session(a_session, didFailWithError:error)
    NSLog("#{self.class}: Session failed #{error}")
  end
end
