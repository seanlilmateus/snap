class HostViewController < UIViewController
  attr_accessor :heading_label, :name_label, :name_text_field, :status_label, :table_view, :start_button
  attr_accessor :delegate
  
  def viewDidLoad
    super
    @heading_label.font   = GameTheme.snap_font(24.0)
    @name_label.font      = GameTheme.snap_font(16.0)
    @name_text_field.font = GameTheme.snap_font(16.0)
    @status_label.font    = GameTheme.snap_font(20.0)
    
    GameTheme.snap_button(@start_button)
    
    gesture_recognizer = UITapGestureRecognizer.alloc.initWithTarget(@name_text_field, action:'resignFirstResponder')
    gesture_recognizer.cancelsTouchesInView = false

    self.view.addGestureRecognizer(gesture_recognizer)
  end
  
  def viewDidAppear(animated)
    super
    @match_server ||= MatchServer.new.tap do |server|
      server.max_clients = 3
      server.startAcceptingConnectionsForSessionID(SESSION_ID)
      @name_text_field.placeholder = server.session.displayName
      @table_view.reloadData
    end
  end
  
  def shouldAutorotateToInterfaceOrientation(interface_orientation)
    interface_orientation == UIInterfaceOrientationLandscapeRight or interface_orientation == UIInterfaceOrientationLandscapeLeft
  end
  
  def start_action(sender)
  end
  
  def exit_action(sender)
    @delegate.host_view_controller_did_cancel(self) if @delegate.respond_to?('host_view_controller_did_cancel:')
  end
  
  # UITableViewDataSOurce
  def tableView(tv, numberOfRowsInSection:section)
    0
  end
  
  def tableView(tv, cellForRowAtIndexPath:index_path)
    nil
  end
  
  # UITextFieldDelegate
  def textFieldShouldReturn(tf)
    tf.resignFirstResponder
    false
  end
end