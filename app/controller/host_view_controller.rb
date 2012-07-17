class HostViewController < UIViewController
  attr_accessor :heading_label, :name_label, :name_text_field, :status_label, :table_view, :start_button
  attr_accessor :delegate

  CELL_ID = "HostCellIdentifier"

  def viewDidLoad
    super
    @heading_label.font   = Game::Theme.snap_font(24.0)
    @name_label.font      = Game::Theme.snap_font(16.0)
    @name_text_field.font = Game::Theme.snap_font(16.0)
    @status_label.font    = Game::Theme.snap_font(20.0)
    
    Game::Theme.snap_button(@start_button)
    
    gesture_recognizer = UITapGestureRecognizer.alloc.initWithTarget(@name_text_field, action:'resignFirstResponder')
    gesture_recognizer.cancelsTouchesInView = false

    self.view.addGestureRecognizer(gesture_recognizer)
  end
  
  def viewDidAppear(animated)
    super
    @match_server ||= MatchServer.alloc.init.tap do |server|
      server.max_clients = 3
      server.delegate = self
      server.startAcceptingConnectionsForSessionID(SESSION_ID)

      @name_text_field.placeholder = server.session.displayName
      @table_view.reloadData
    end
  end
  
  def shouldAutorotateToInterfaceOrientation(interface_orientation)
    interface_orientation == UIInterfaceOrientationLandscapeRight or interface_orientation == UIInterfaceOrientationLandscapeLeft
  end
  
  def start_action(sender)
    if (!@match_server.nil? and @match_server.connected_clients_count > 0)
      name = @name_text_field.text.strip

      NSLog("name: %@", name)

      name = @match_server.session.displayName if name.empty?
      @match_server.stopAcceptingConnections
      @delegate.hostViewController(self, startGameWithSession:@match_server.session, playerName:name, clients:@match_server.connected_clients)
    end
  end
  
  def exit_action(sender)
    @quit_reason = QuitReasonUserQuit
    @match_server.end_session
    @delegate.hostViewControllerDidCancel(self) if @delegate.respond_to?('hostViewControllerDidCancel:')
  end
  
  # UITableViewDataSOurce
  def tableView(tv, numberOfRowsInSection:section)
    @match_server ? @match_server.connected_clients_count : 0
  end
  
  def tableView(tv, cellForRowAtIndexPath:index_path)
    (tv.dequeueReusableCellWithIdentifier(CELL_ID) || PeerCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CELL_ID))
    .tap do |cell|
      peer_id = @match_server.peerIDForConnectedClientAtIndex(index_path.row)
      cell.textLabel.text = @match_server.displayNameForPeerID(peer_id)
    end
  end
  
  # UITableViewDelegate
  def tableView(tv, willSelectRowAtIndexPath:index_path)
    nil
  end

  # UITextFieldDelegate
  def textFieldShouldReturn(tf)
    tf.resignFirstResponder
    false
  end

  # MatchServer Delegate
  def matchServer(server, clientDidConnect:peer_id)
    @table_view.reloadData
  end

  def matchmakingServer(server, clientDidDisconnect:peer_id)
    @table_view.reloadData
  end

  def matchServerSessionDidEnd(server)
    @match_server.delegate = nil
    @match_server = nil
    @table_view.reloadData
    @delegate.hostViewController(self, didEndSessionWithReason:@quit_reason)
  end

  def matchServerNoNetwork(session)
    @quit_reason = QuitReasonNoNetwork
  end

  def dealloc
    NSLog("dealloc %@", self)
  end
end