class JoinViewController < UIViewController
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
  end
  
  def viewDidAppear(animated)
    super
    @match_client ||= MatchClient.new.tap do |client|
      client.startSearchingForServersWithSessionID(SESSION_ID)
      @name_text_field.placeholder = client.session.displayName
      @table_view.reloadData
    end
  end
  
  def shouldAutorotateToInterfaceOrientation(interface_orientation)
    interface_orientation == UIInterfaceOrientationLandscapeRight or interface_orientation == UIInterfaceOrientationLandscapeLeft
  end
  
  def exit_action(sender)
    @delegate.join_view_controller_did_cancel(self) if @delegate.respond_to?('join_view_controller_did_cancel:')
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