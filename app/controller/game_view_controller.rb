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
    @dealing_cards_sound.stop
	  AVAudioSession.sharedInstance.setActive(false, error:nil)
	end

	def viewDidLoad
		super
		@center_label.font = TheGame::Theme.snap_font(18.0)
    [@snap_button, @next_round_button, 
     @wrong_snap_image_view, @correct_snap_image_view].map { |v| v.hidden = true }
    hide_player_labels
    hide_active_player_indicator
    hide_snap_indicators
    load_sounds
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
    when TheGame::PlayerPosition::Bottom 
      [@bottom_player_name_label, @bottom_player_wins_label].map { |v| v.hidden = true }
    when TheGame::PlayerPosition::Left
      [@left_player_name_label, @left_player_wins_label].map { |v| v.hidden = true }
    when TheGame::PlayerPosition::Top
      [@top_player_name_label, @top_player_wins_label].map { |v| v.hidden = true }
    when TheGame::PlayerPosition::Right
      [@right_player_name_label, @right_player_wins_label].map { |v| v.hidden = true }
    end
  end

  def hide_active_indicator_for_player(player)
    case player.position
    when TheGame::PlayerPosition::Bottom then @bottom_player_active_imageview.hidden = true
    when TheGame::PlayerPosition::Left   then @left_player_active_imageview.hidden   = true
    when TheGame::PlayerPosition::Top    then @top_player_active_imageview.hidden    = true
    when TheGame::PlayerPosition::Right  then @right_player_active_imageview.hidden  = true
    end
  end
  
  def hide_snap_indicator_for_player(player)
    case player.position
    when TheGame::PlayerPosition::Bottom then @bottom_snap_indicator_imageview.hidden = true
    when TheGame::PlayerPosition::Left   then @left_snap_indicator_imageview.hidden   = true
    when TheGame::PlayerPosition::Top    then @top_snap_indicator_imageview.hidden    = true
    when TheGame::PlayerPosition::Right  then @right_snap_indicator_imageview.hidden  = true
    end
  end
  
  def load_sounds
    audio_session = AVAudioSession.sharedInstance
    audio_session.delegate = nil
    audio_session.setCategory(AVAudioSessionCategoryAmbient, error:nil)
    audio_session.setActive(true, error:nil)
    
    url = NSBundle.mainBundle.URLForResource("Dealing", withExtension:"caf", subdirectory:"sounds")
    @dealing_cards_sound = AVAudioPlayer.alloc.initWithContentsOfURL(url, error:nil)
    @dealing_cards_sound.numberOfLoops = -1
    @dealing_cards_sound.prepareToPlay
    
    url = NSBundle.mainBundle.URLForResource("TurnCard", withExtension:"caf", subdirectory:"sounds")
    @turn_card_sound = AVAudioPlayer.alloc.initWithContentsOfURL(url, error:nil)
    @turn_card_sound.prepareToPlay
  end
  
  
  def show_tapped_view
    player = @game.player_at_position(TheGame::PlayerPosition::Bottom)
    card = player.closed_cards.top_most_card
    unless card.nil?
      card_view = cardview_for_card(card)
      if @tapped_view.nil?
        @tapped_view = UIImageView.alloc.initWithFrame(card_view.bounds)
        @tapped_view.backgroundColor = UIColor.clearColor
        @tapped_view.image = UIImage.imageNamed("Darken")   
        @tapped_view.alpha = 0.6
        self.view.addSubView(@tapped_view)
      else
        @tapped_view.hidden = false  
      end
      
      @tapped_view.center = card_view.center
      @tapped_view.transform = card_view.transform
    end
  end
  
  def hide_tapped_view
    @tapped_view.hidden = true
  end
  
  def cardview_for_card(card)
    @card_container_view.subviews.select { |card_view| card_view == card }.first
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
  
  def gameShouldDealCards(game, startingWithPlayer:starting_player)
    @center_label.text = NSLocalizedString("Dealing...", "Status text: dealing")
    
    @snap_button.hidden = true
    @next_round_button.hidden = true
    
    delay = 1.0
    
    @dealing_cards_sound.currentTime = 0.0
    @dealing_cards_sound.prepareToPlay
    @dealing_cards_sound.performSelector(:play, withObject:nil, afterDelay:delay)
    
    26.times do |t|
      starting_player.position.upto(starting_player.position + 4) do |pos|
        player = @game.player_at_position(pos % 4)
        if !player.nil? and t < player.closed_cards.cards_count
          card_view = CardView.alloc.initWithFrame(CGRectMake(0, 0, CardWidth, CardHeight))
          card_view.card = player.closed_cards[t]
          @card_container_view.addSubView(card_view)
          card_view.animateDealingToPlayer(player, withDelay:delay)
          delay += 0.1
        end
      end
    end
    
    self.performSelector(:after_dealing, withObject:nil, afterDelay:delay)
  end
  
  def after_dealing
    @dealing_cards_sound.stop
    @snap_button.hidden = false
    @game.begin_round
  end
  
  def game(game, didActivatePlayer:player)
    show_active_player_indicator
    @snap_button.enabled = true
  end
  
  def show_active_player_indicator
    hide_active_player_indicator
    
    position = @game.active_player.position
    case position
    when TheGame::PlayerPosition::Bottom then @bottom_player_active_imageview.hidden = false
    when TheGame::PlayerPosition::Left   then @left_player_active_imageview.hidden   = false
    when TheGame::PlayerPosition::Top    then @top_player_active_imageview.hidden    = false
    when TheGame::PlayerPosition::Right  then @right_player_active_imageview.hidden  = false
    end
    
    @center_label.text = if position == TheGame::PlayerPosition::Bottom
                            NSLocalizedString("Your turn. Tap the stack.", "Status text: your turn")
                         else
                           NSLocalizedString("#{@game.active_player.name}'s turn", "Status text: other player's turn")
                         end
  end
  
  def game(game, player:player, turnedOverCard:card)
    @turn_card_sound.play
    card_view = cardview_for_card(card)
    card_view.animate_turning_over_for_player(player)
  end
  
  ### action
  def exit_action(sender)
    alert = if @game.is_server?
              {   
                  title: NSLocalizedString("End Game?", "Alert title (user is host)"),
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
  
  def turn_over_pressed(sender)
    show_tapped_view
  end
  
  def turn_over_enter(sender)
    show_tapped_view
  end
  
  def turn_over_exit(sender)
    hide_tapped_view
  end
  
  def turn_over_action(sender)
    hide_tapped_view
  end
  
  def snap_action(sender)
    puts :action
  end
  
  def next_round_action(sender)
  end
  
  def show_player_labels
    positions = [TheGame::PlayerPosition::Bottom, TheGame::PlayerPosition::Left, 
                 TheGame::PlayerPosition::Top, TheGame::PlayerPosition::Right]
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
    positions = [TheGame::PlayerPosition::Bottom, TheGame::PlayerPosition::Left, 
                 TheGame::PlayerPosition::Top, TheGame::PlayerPosition::Right]
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
    font = TheGame::Theme.snap_font(14.0)
    [@bottom_player_name_label, @left_player_name_label, 
     @top_player_name_label, @right_player_name_label].map { |v| v.font = font }
    
    font = TheGame::Theme.snap_font(11.0)
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
    
    player = @game.player_at_position(TheGame::PlayerPosition::Bottom)
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
    
    player = @game.player_at_position(TheGame::PlayerPosition::Left)
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
    
    player = @game.player_at_position(TheGame::PlayerPosition::Top)
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
    
    player = @game.player_at_position(TheGame::PlayerPosition::Right)
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
    unless button_index == av.cancelButtonIndex
      NSObject.cancelPreviousPerformRequestsWithTarget(self)
      @game.quit_with_reason(QuitReasonUserQuit) 
    end
  end
end
