class MainViewController < UIViewController    
  attr_accessor :s_imageview, :n_imageview,:a_imageview, :p_imageview,  :joker_imageview
  attr_accessor :host_game_button, :join_game_button, :single_player_game_button
  
  def viewDidLoad
    GameTheme.snap_button(@host_game_button, @join_game_button, @single_player_game_button) # customize the buttons
  end
  
  def viewWillAppear(animated)
    super
    prepare_intro_animation
  end
  
  def viewDidAppear(animated)
    super
    perform_intro_animation
  end
  
  def shouldAutorotateToInterfaceOrientation(interface_orientation)
    interface_orientation == UIInterfaceOrientationLandscapeRight or interface_orientation == UIInterfaceOrientationLandscapeLeft
  end
  
  def buttons_enabled?; @buttons_enabled; end
  
  def host_game(sender)
    if buttons_enabled?
      perform_exit_animation do |finished|
        controller = HostViewController.alloc.initWithNibName("HostViewController", bundle:nil)
        controller.delegate = self
        
        self.presentViewController(controller, animated:false, completion:->{})
      end
    end
  end
  
  def join_game(sender)
    if buttons_enabled?
      perform_exit_animation do |finished|
        controller = JoinViewController.alloc.initWithNibName("JoinViewController", bundle:nil)
        controller.delegate = self
        
        self.presentViewController(controller, animated:false, completion:->{})
      end
    end
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
  def host_view_controller_did_cancel(controller)
    self.dismissViewControllerAnimated(false, completion:-> {})
  end
  
  # JoinViewControllerDelegate
  def join_view_controller_did_cancel(controller)
    self.dismissViewControllerAnimated(false, completion:-> {})
  end
end