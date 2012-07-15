class JoinViewController < UIViewController
  
  CELL_ID = "JoinCellIdentifier"

  attr_accessor :heading_label, :name_label, :name_text_field, :status_label, :table_view
  attr_accessor :wait_view, :wait_label, :delegate

  def viewDidLoad
    super
    @heading_label.font   = GameTheme.snap_font(24.0)
    @name_label.font      = GameTheme.snap_font(16.0)
    @status_label.font    = GameTheme.snap_font(16.0)
    @wait_label.font      = GameTheme.snap_font(18.0)
    @name_text_field.font = GameTheme.snap_font(20.0)
    
    gesture_recognizer = UITapGestureRecognizer.alloc.initWithTarget(@name_text_field, action:'resignFirstResponder')
    gesture_recognizer.cancelsTouchesInView = false

    self.view.addGestureRecognizer(gesture_recognizer)
  end
  
  def viewDidUnload
    @wait_view = nil
    @match_client = nil
  end
  
  def viewDidAppear(animated)
    super
    @match_client ||= MatchClient.alloc.init.tap do |clt|
      clt.delegate = self
      clt.startSearchingForServersWithSessionID(SESSION_ID)

      @name_text_field.placeholder = clt.session.displayName
      @table_view.reloadData
    end
  end
  
  def shouldAutorotateToInterfaceOrientation(interface_orientation)
    interface_orientation == UIInterfaceOrientationLandscapeRight or interface_orientation == UIInterfaceOrientationLandscapeLeft
  end
  
  def exit_action(sender)
    @quit_reason = QuitReasonUserQuit
    @match_client.disconnect_from_server
    @delegate.joinViewControllerDidCancel(self) if @delegate.respond_to?('joinViewControllerDidCancel:')
  end
  
  # UITableViewDataSource
  def tableView(tv, numberOfRowsInSection:section)
    @match_client.nil? ? 0 : @match_client.available_server_count
  end
  
  def tableView(tv, cellForRowAtIndexPath:index_path)
    (tv.dequeueReusableCellWithIdentifier(CELL_ID) || PeerCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CELL_ID))
    .tap do |cell|
      peer_id = @match_client.peerIDForAvailableServerAtIndex(index_path.row)
      cell.textLabel.text = @match_client.displayNameForPeerID(peer_id)
    end
  end
  
  # UITableViewDataDelegate
  def tableView(tv, didSelectRowAtIndexPath:index_path)
    tv.deselectRowAtIndexPath(index_path, animated:true)
    self.view.addSubview(@wait_view)
    peer_id = @match_client.peerIDForAvailableServerAtIndex(index_path.row)
    @match_client.connectToServerWithPeerID(peer_id)
  end

  # UITextFieldDelegate
  def textFieldShouldReturn(tf)
    tf.resignFirstResponder
    false
  end

  # MatchClientDelegate
  def matchClient(client, serverBecameAvailable:peer_id)
    @table_view.reloadData
  end

  def matchClient(client, serverBecameUnavailable:peer_id)
    @table_view.reloadData
  end

  def matchClient(client, didDisconnectFromServer:peer_id)
    @match_client.delegate = nil
    @table_view.reloadData
    @delegate.joinViewController(self, didDisconnectWithReason:@quit_reason)
  end

  def matchClientNoNetwork(client)
    @quit_reason = QuitReasonNoNetwork
  end

  def dealloc
    NSLog("dealloc %@", self)
  end

end