class GameViewController < UIViewController
	attr_accessor :center_label, :delegate, :game
	attr_accessor :bg_image_view, :card_container_view, :turn_over_button, :snap_button,
                :next_round_button, :wrong_snap_image_view, :correct_snap_image_view
                
  attr_accessor :bottom_player_name_label, :left_player_name_label, 
                :top_player_name_label, :right_player_name_label
                
  attr_accessor :bottom_player_wins_label, :left_player_wins_label, 
                :top_player_wins_label, :right_player_wins_label
  
  attr_accessor :bottom_player_active_imageview, :left_player_active_imageview,
                :top_player_active_imageview, :right_player_active_imageview
                
  attr_accessor :bottom_snap_indicator_imageview, :left_snap_indicator_imageview,
                :top_snap_indicator_imageview, :right_snap_indicator_imageview
	def dealloc
		NSLog("dealloc %@", self) if DEBUG
	end

	def viewDidLoad
		super
		@center_label.font = Game::Theme.snap_font(18.0)
    [@snap_button, @next_round_button, 
     @wrong_snap_image_view, @correct_snap_image_view].map { |v| v.hidden = true }
    hide_player_labels
    hide_active_player_indicator
    hide_snap_indicators
	end

	def shouldAutorotateToInterfaceOrientation(interface_orientation)
    	interface_orientation == UIInterfaceOrientationLandscapeRight or 
      interface_orientation == UIInterfaceOrientationLandscapeLeft
  end
  
  def viewWillDisappear(animated)
    super
    @alert_view.dismissWithClickedButtonIndex(@alert_view.cancelButtonIndex, animated:false) if @alert_view
  end
  
  def hide_player_labels
    [@bottom_player_name_label, @bottom_player_wins_label,
     @left_player_name_label, @left_player_wins_label,
     @top_player_name_label, @top_player_wins_label,
     @right_player_name_label, @right_player_wins_label].map { |v| v.hidden = true }
  end
  
  def hide_active_player_indicator
    [@bottom_player_active_imageview, @left_player_active_imageview,
     @top_player_active_imageview, @right_player_active_imageview].map { |v| v.hidden = true }
  end
  
  def hide_snap_indicators
    [@bottom_snap_indicator_imageview, @left_snap_indicator_imageview,
     @top_snap_indicator_imageview, @right_snap_indicator_imageview].map { |v| v.hidden = true }
  end
  
  def hide_player_labels_for_player(player)
    case player.position
    when Game::PlayerPosition::Bottom 
      [@bottom_player_name_label, @bottom_player_wins_label].map { |v| v.hidden = true }
    when Game::PlayerPosition::Left
      [@left_player_name_label, @left_player_wins_label].map { |v| v.hidden = true }
    when Game::PlayerPosition::Top
      [@top_player_name_label, @top_player_wins_label].map { |v| v.hidden = true }
    when Game::PlayerPosition::Right
      [@right_player_name_label, @right_player_wins_label].map { |v| v.hidden = true }
    end
  end

  def hide_active_indicator_for_player(player)
    case player.position
    when Game::PlayerPosition::Bottom then @bottom_player_active_imageview.hidden = true
    when Game::PlayerPosition::Left   then @left_player_active_imageview.hidden   = true
    when Game::PlayerPosition::Top    then @top_player_active_imageview.hidden    = true
    when Game::PlayerPosition::Right  then @right_player_active_imageview.hidden  = true
    end
  end
  
  def hide_snap_indicator_for_player(player)
    case player.position
    when Game::PlayerPosition::Bottom then @bottom_snap_indicator_imageview.hidden = true
    when Game::PlayerPosition::Left   then @left_snap_indicator_imageview.hidden   = true
    when Game::PlayerPosition::Top    then @top_snap_indicator_imageview.hidden    = true
    when Game::PlayerPosition::Right  then @right_snap_indicator_imageview.hidden  = true
    end
  end
  
  def exit_action(sender)
    alert = if @game.is_server?
              {   
                title: NSLocalizedString("End Game?" "Alert title (user is host)"),
                message: NSLocalizedString("This will terminate the game for all other players.", "Alert message (user is host)")
              }
            else
              { title: NSLocalizedString("Leave Game?", "Alert title (user is not host)") }
            end
            
    @alert_view = UIAlertView.alloc.initWithTitle( alert[:title], 
                                          message: alert[:message],
                                         delegate: self,
                                cancelButtonTitle: NSLocalizedString("No", "Button: No"),
                                otherButtonTitles: NSLocalizedString("Yes", "Button: Yes"))
    @alert_view.show
  end

  
	# Game Delegate
  def gameDidBegin(game)
    self.show_player_labels
    self.calculate_label_frames
    self.update_wins_labels
  end
  
	def game(game, didQuitWithReason:reason)
		@delegate.gameViewController(self, didQuitWithReason:reason)
	end

	def gameWaitingForServerReady(game)
		@center_label.text = NSLocalizedString("Waiting for game to start...", "Status text: waiting for server")
	end

	def gameWaitingForClientsReady(game)
		@center_label.text = NSLocalizedString("Waiting for other players...", "Status text: waiting for clients")
	end
  
  def game(game, playerDidDisconnect:disconnected_player)
    hide_player_labels_for_player(disconnected_player)
    hide_active_indicator_for_player(disconnected_player)
    hide_snap_indicator_for_player(disconnected_player)
  end
  
  ### action
  def turn_over_pressed(sender)
  end
  
  def turn_over_enter(sender)
  end
  
  def turn_over_exit(sender)
  end
  
  def turn_over_action(sender)
  end
  
  def snap_action(sender)
  end
  
  def next_round_action(sender)
  end
  
  def show_player_labels
    positions = [Game::PlayerPosition::Bottom, Game::PlayerPosition::Left, 
                 Game::PlayerPosition::Top, Game::PlayerPosition::Right]
    labels = [{win: @bottom_player_wins_label, name: @bottom_player_name_label},
              {win: @left_player_wins_label,   name: @left_player_wins_label},
              {win: @top_player_wins_label,    name: @top_player_wins_label},
              {win: @right_player_name_label,  name: @right_player_name_label}]
    
    positions.zip(labels) do |position, label|
      player = @game.player_at_position(position)
      unless player.nil?
        label[:win].hidden = false
        label[:name].hidden = false
      end
    end
  end
  
  def update_wins_labels
    format = NSLocalizedString("%@ Won", "Number of games won")
    positions = [Game::PlayerPosition::Bottom, Game::PlayerPosition::Left, 
                 Game::PlayerPosition::Top, Game::PlayerPosition::Right]
    labels = [@bottom_player_wins_label, @left_player_wins_label, 
              @top_player_wins_label, @right_player_wins_label ]
              
    positions.zip(labels) do |position, label|
      player = @game.player_at_position(position)
      unless player.nil?
        label.text = NSString.stringWithFormat(format, player.games_won)
      end
    end
  end
  
  def resize_label_to_fit(label)
    label.sizeToFit
    
    rect = label.frame
    rect.size.width  = (rect.size.width  / 2.0).ceil * 2.0 # make even
    rect.size.height = (rect.size.height / 2.0).ceil * 2.0 # make even
    label.frame = rect
  end
  
  def calculate_label_frames
    font = Game::Theme.snap_font(14.0)
    [@bottom_player_name_label, @left_player_name_label, 
     @top_player_name_label, @right_player_name_label].map { |v| v.font = font }
    
    font = Game::Theme.snap_font(11.0)
    [@bottom_player_wins_label, @left_player_wins_label, 
     @top_player_wins_label, @right_player_wins_label].map do |v| 
       v.font = font
       v.layer.cornerRadius = 4.0
    end
     
    image = UIImage.imageNamed("ActivePlayer").stretchableImageWithLeftCapWidth(20, topCapHeight:0)
    [@bottom_player_active_imageview, @left_player_active_imageview,
     @top_player_active_imageview, @right_player_active_imageview].map { |v| v.image = image }
     
    view_wdth = self.view.bounds.size.width
    center_x = view_wdth / 2.0
    
    player = @game.player_at_position(Game::PlayerPosition::Bottom)
    unless player.nil?
      @bottom_player_name_label.text = player.name
      
      resize_label_to_fit(@bottom_player_name_label)
      label_width = @bottom_player_name_label.bounds.size.width
      
      point = CGPointMake(center_x - 19.0 - 3.0, 306.0)
      @bottom_player_name_label.center = point
      
      wins_point = point
      wins_point.x += (label_width / 2.0) + 6.0 + 19.0
      wins_point.y -= 0.5
      @bottom_player_wins_label.center = wins_point
      
      @bottom_player_active_imageview.frame = CGRectMake(0, 0, 20.0 + label_width + 6.0 + 38.0 + 2.0, 20.0)
      
      point.x = center_x - 9.0
      @bottom_player_active_imageview.center = point
    end
    
    player = @game.player_at_position(Game::PlayerPosition::Left)
    unless player.nil?
      @left_player_name_label.text = player.name
      
      resize_label_to_fit(@left_player_name_label)
      label_width = @left_player_name_label.bounds.size.width
      
      point = CGPointMake(2.0 + 20.0 - (label_width / 2.0), 48.0)
      @left_player_name_label.center = point
      
      wins_point = point
      wins_point.x += (label_width / 2.0) + 6.0 + 19.0
      wins_point.y -= 0.5
      @left_player_wins_label.center = wins_point

      @left_player_active_imageview.frame = CGRectMake(2.0, 38.0, 20.0 + label_width + 6.0 + 38.0 + 2.0, 20.0)      
    end
    
    player = @game.player_at_position(Game::PlayerPosition::Top)
    unless player.nil?
      @top_player_name_label.text = player.name
      
      resize_label_to_fit(@top_player_name_label)
      label_width = @top_player_name_label.bounds.size.width
      
      point = CGPointMake(center_x - 19.0 - 3.0, 15.0)
      @top_player_name_label.center = point
      
      wins_point = point
      wins_point.x += (label_width / 2.0) + 6.0 + 19.0
      wins_point.y -= 0.5
      @top_player_wins_label.center = wins_point
      
      @top_player_active_imageview.frame = CGRectMake(0.0, 0.0, 20.0 + label_width + 6.0 + 38.0 + 2.0, 20.0)
      point.x = center_x - 9.0
      @top_player_active_imageview.center = point
    end
    
    player = @game.player_at_position(Game::PlayerPosition::Right)
    unless player.nil?
      @right_player_name_label.text = player.name
      
      resize_label_to_fit(@right_player_name_label)
      label_width = @right_player_name_label.bounds.size.width
      
      point = CGPointMake(((view_wdth - label_width) / 2.0) - 2.0 - 6.0 - 38.0 - 12.0, 48.0)
      @right_player_name_label.center = point
      
      wins_point = point
      wins_point.x += (label_width / 2.0) + 6.0 + 19.0
      wins_point.y -= 0.5
      @right_player_wins_label.center = wins_point
      
      @right_player_active_imageview.frame = CGRectMake(@right_player_name_label.frame.origin.x - 20.0, 38.0, 
                                                          20.0 + label_width + 6.0 + 38.0 + 2.0, 20.0)      
    end
  end
  
  def alertView(av, didDismissWithButtonIndex:button_index)
    @game.quit_with_reason(QuitReasonUserQuit) unless button_index == av.cancelButtonIndex
  end
end
