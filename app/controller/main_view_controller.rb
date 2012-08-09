class MainViewController < UIViewController    
  attr_accessor :s_imageview, :n_imageview,:a_imageview, :p_imageview,  :joker_imageview
  attr_accessor :host_game_button, :join_game_button, :single_player_game_button
  
  def initWithNibName(nib_name, bundle:nib_bundle)
    super.tap { @perform_animations = true }
  end

  def viewDidLoad
    Game::Theme.snap_button(@host_game_button, @join_game_button, @single_player_game_button) # customize the buttons
  end
  
  def viewWillAppear(animated)
    super
    prepare_intro_animation if @perform_animations
  end
  
  def viewDidAppear(animated)
    super
    perform_intro_animation if @perform_animations
  end
  
  def shouldAutorotateToInterfaceOrientation(interface_orientation)
    interface_orientation == UIInterfaceOrientationLandscapeRight or interface_orientation == UIInterfaceOrientationLandscapeLeft
  end
  
  def buttons_enabled?; @buttons_enabled; end
  
  def host_game(sender)
    perform_exit_animation do |finished|
      controller = HostViewController.alloc.initWithNibName("HostViewController", bundle:nil)
      controller.delegate = self
        
      self.presentViewController(controller, animated:false, completion:->{})
    end if buttons_enabled?
  end
  
  def join_game(sender)
    perform_exit_animation do |finished|
      controller = JoinViewController.alloc.initWithNibName("JoinViewController", bundle:nil)
      controller.delegate = self
        
      self.presentViewController(controller, animated:false, completion:->{})
    end if buttons_enabled?
  end
  
  def single_player_game(sender)
    NSLog("Single Player coming soon")
  end
  
  def prepare_intro_animation
    [@joker_imageview, @s_imageview, @n_imageview, @p_imageview, @a_imageview].map { |image_view| image_view.hidden = true }
    
    @host_game_button.alpha = @join_game_button.alpha = @single_player_game_button.alpha = 0.0
    @buttons_enabled = false
  end
  
  def perform_intro_animation
    image_views = [@joker_imageview, @s_imageview, @n_imageview, @p_imageview, @a_imageview]
    image_views.map { |image_view| image_view.hidden = false }
    
    point = [self.view.bounds.size.width / 2.0, self.view.bounds.size.height * 2.0] 
    
    image_views.map { |image_view| image_view.center = point }
    
    UIView.animateWithDuration(0.65, delay:0.5, options:UIViewAnimationOptionCurveEaseOut, animations:-> {
      @s_imageview.center = [80.0, 108.0]
      @s_imageview.transform = CGAffineTransformMakeRotation(-0.22)
      
      @n_imageview.center = [160.0, 93.0]
      @n_imageview.transform = CGAffineTransformMakeRotation(-0.1)
      
      @a_imageview.center = [240.0, 88.0]
      
      @p_imageview.center = [320.0, 93.0]
      @p_imageview.transform = CGAffineTransformMakeRotation(0.1)
      
      @joker_imageview.center = [400.0, 108.0]
      @joker_imageview.transform = CGAffineTransformMakeRotation(0.22)
    }, completion:-> finished { })
    
    UIView.animateWithDuration(0.5, delay:1.0, options:UIViewAnimationOptionCurveEaseOut, animations:-> {
      @host_game_button.alpha = 1.0
      @join_game_button.alpha = 1.0
      @single_player_game_button.alpha = 1.0
    }, completion:-> finished { @buttons_enabled = true })
  end
  
  def perform_exit_animation(&block)
    @buttons_enabled = false
    
    UIView.animateWithDuration(0.3, delay:0.0, options:UIViewAnimationOptionCurveEaseOut, animations:-> {
      @s_imageview.center = @a_imageview.center
      @s_imageview.transform = @a_imageview.transform
      
      @n_imageview.center = @a_imageview.center
      @n_imageview.transform = @a_imageview.transform
            
      @p_imageview.center = @a_imageview.center
      @p_imageview.transform = @a_imageview.transform
      
      @joker_imageview.center = @a_imageview.center
      @joker_imageview.transform = @a_imageview.transform
    }, completion:-> finished {  
      
      point = [@a_imageview.center.x, self.view.frame.size.height * -2.0]
      
      UIView.animateWithDuration(1.0, delay:0.0, options:UIViewAnimationOptionCurveEaseOut, animations:-> {
        [@joker_imageview, @s_imageview, @n_imageview, @p_imageview, @a_imageview].map { |image_view| image_view.center = point }
      }, completion:block)
      
      UIView.animateWithDuration(0.3, delay:0.3, options:UIViewAnimationOptionCurveEaseOut, animations:-> {
        @host_game_button.alpha = @join_game_button.alpha = @single_player_game_button.alpha = 0.0
      }, completion:-> finished {})      
    })
  end
  
  # HostViewControllerDelegate
  def hostViewControllerDidCancel(controller)
    self.dismissViewControllerAnimated(false, completion:-> {})
  end
  
  def hostViewController(controller, didEndSessionWithReason:reason)
    self.showNoNetworkAlert if reason == QuitReasonNoNetwork
  end

  def hostViewController(controller, startGameWithSession:session, playerName:name, clients:clients)
    @perform_animations = false
    self.dismissViewControllerAnimated(false, completion:-> {
      @perform_animations = true
      start_game { |game| game.startServerGameWithSession(session, playerName:name, clients:clients) }
    })
  end

  # JoinViewControllerDelegate
  def joinViewControllerDidCancel(controller)
    self.dismissViewControllerAnimated(false, completion:-> {})
  end

  def joinViewController(controller, didDisconnectWithReason:reason)
    if reason == QuitReasonNoNetwork
      self.showNoNetworkAlert
    elsif reason == QuitReasonConnectionDropped
      self.dismissViewControllerAnimated(false, completion:->{ self.showNoNetworkAlert })
    end
  end

  def joinViewController(controller, startGameWithSession:session, playerName:name, server:peer_id)
    @perform_animations = false
    self.dismissViewControllerAnimated(false, completion:-> { 
      @perform_animations = true
      start_game { |game| game.startClientGameWithSession(session, playerName:name, server:peer_id) }
    })
  end

  # GameViewControllerDelegate
  def gameViewController(controller, didQuitWithReason:reason)
    self.dismissViewControllerAnimated(false, completion:-> {
      showDisconnectedAlert if reason == QuitReasonConnectionDropped
    })
  end

  def showNoNetworkAlert
    title = NSLocalizedString("No Network", "No network alert title")
    msg = NSLocalizedString("To use multiplayer, please enable Bluetooth or Wi-Fi in your device's Settings.", "No network alert message")
    cancel_btn = NSLocalizedString("OK", "Button: OK")
    UIAlertView.alloc.initWithTitle(title, message:msg, delegate:nil, cancelButtonTitle:cancel_btn, otherButtonTitles:nil).show
  end

  def showDisconnectedAlert
    title = NSLocalizedString("Disconnected", "Client disconnected alert title")
    msg = NSLocalizedString("You were disconnected from the game.", "Client disconnected alert message")
    cancel_btn = NSLocalizedString("OK", "Button: OK")
    UIAlertView.alloc.initWithTitle(title, message:msg, delegate:nil, cancelButtonTitle:cancel_btn, otherButtonTitles:nil).show
  end

  def start_game
    game_view_controller = GameViewController.alloc.initWithNibName("GameViewController", bundle:nil)
    game_view_controller.delegate = self
    self.presentViewController(game_view_controller, animated:false, completion:-> {
      game = Game.alloc.init
      game.delegate = game_view_controller
      game_view_controller.game = game
      yield(game) if block_given?
    })
  end

  def dealloc
    NSLog("dealloc %@", self) if DEBUG
  end
end