class CardView < UIView
  include TheGame::PlayerPosition
  include TheGame::Suit
  
  # this includes drop shadows
  CardWidth = 67.0
  CardHeight = 99.0
  attr_accessor :card
  
  def initWithFrame(frame)
    super.tap do |cv| 
      cv.backgroundColor = UIColor.clearColor
      load_back
    end
  end
  
  def load_back
    @back_image_view ||= UIImageView.alloc.initWithFrame(self.bounds).tap do |iv|
      iv.image = UIImage.imageNamed("Back")
      iv.contentMode = UIViewContentModeScaleToFill
      self.addSubview(iv)
    end
  end
  
  def animateDealingToPlayer(player, withDelay:delay)
    self.frame = CGRectMake(-100.0, -100.0, CardWidth, CardHeight)
    self.transform = CGAffineTransformMakeRotation(Math::PI)
    
    point = center_for_player(player)
    @angle = angle_for_player(player)
    
  	UIView.animateWithDuration(0.2, delay:delay, options:UIViewAnimationOptionCurveEaseOut, animations:-> {
  	  self.center = point
      self.transform = CGAffineTransformMakeRotation(@angle)
  	}, completion:-> finished {})
  end
  
  def center_for_player(player)
    rect = self.superview.bounds
    midX = CGRectGetMidX(rect)
    midY = CGRectGetMidY(rect)
  	maxX = CGRectGetMaxX(rect)
  	maxY = CGRectGetMaxY(rect)
    
    random = Random.new
        
    x = -3.0 + random.rand(0..6) + CardWidth / 2.0
    y = -3.0 + random.rand(0..6) + CardHeight / 2.0
    
    if @card.is_turned_over
      if player.position == Bottom
        x += midX + 7.0
        y += maxY - CardHeight - 30.0
      elsif player.position == Left
        x += 31.0
        y += midY - 30.0
      elsif player.position == Top
        x += midX - CardWidth - 7.0
        y += 29.0
      else
        x += maxX - CardHeight + 1.0
        y += midY - CardWidth - 45.0
      end
    else
      if player.position == Bottom
        x += midX - CardWidth - 7.0
        y += maxY - CardHeight - 30.0
      elsif player.position == Left
        x += 31.0
        y += midY - CardWidth - 45.0
      elsif player.position == Top
        x += midX + 7.0
        y += 29.0
      else
        x += maxX -CardHeight + 1.0
        y += midY - 30.0
      end
    end
    CGPointMake(x, y)
  end
  
  def unload_back
    @back_image_view.removeFromSuperview
    @back_image_view = nil
  end
  
  def load_front
    @front_image_view ||= UIImageView.alloc.initWithFrame(self.bounds).tap do |iv|
      iv.contentMode = UIViewContentModeScaleToFill
      iv.hidden = true
      self.addSubview(iv)
      suit_string = case @card.suit
                    when Clubs    then "Clubs"
                    when Diamonds then "Diamonds"
                    when Hearts   then "Hearts"
                    when Spades   then "Spades"
                    end
                    
      value_str =   case @card.value
                    when CardAce    then "Ace"
                    when CardJack   then "Jack"
                    when CardQueen  then "Queen"
                    when CardKing   then "King"
                    else "#{card.value}"
                    end
      file_name = "#{suit_string} #{value_str}"
      iv.image = UIImage.imageNamed(file_name)
    end
  end
  
  def angle_for_player(player)
    random = Random.new
    the_angle = (-0.5 + random.rand(0.0..1.0)) / 4.0
    
    the_angle = if player.position == Left
                  the_angle + Math::PI / 2.0
                elsif player.position == Top
                  the_angle + Math::PI
                elsif player.position == Right
                  the_angle - Math::PI
                end
  end
  
  def animate_turning_over_for_player(player)
    load_front
    self.superview.bringSubviewToFront(self)
    
    darken_view = UIImageView.alloc.initWithFrame(self.bounds)
    darken_view.backgroundColor = UIColor.clearColor
    darken_view.image = UIImage.imageNamed("Darken")
    darken_view.alpha = 0.0
    self.addSubview(darken_view)
    
    start_point = self.center
    end_point = center_for_player(player)
    after_angle = angle_for_player(player)
    
    halfway_point = CGPointMake((start_point.x + end_point.x)/2.0, (start_point.y + end_point.y)/2.0)
    halfway_angle = (@angle + after_angle) / 2.0
    
  	UIView.animateWithDuration(0.15, delay:0.0, options:UIViewAnimationOptionCurveEaseIn, animations:->{
  	  rect = @back_image_view.bounds
      rect.size.width = 1.0
      @back_image_view.bounds = rect
      
      darken_view.bounds = rect
      darken_view.alpha = 0.5
      
      self.center = halfway_point
      self.transform = CGAffineTransformScale(CGAffineTransformMakeRotation(halfway_angle), 1.2, 1.2)
  	}, completion:-> finished {
  	  @front_image_view.bounds = @back_image_view.bounds
      @front_image_view.hidden = false
      
      UIView.animateWithDuration(0.15, delay:0, options:UIViewAnimationOptionCurveEaseOut, animations:-> {
        rect = @front_image_view.bounds
        rect.size.width = CardWidth
        @front_image_view.bounds = rect
        
        darken_view.bounds = rect
        darken_view.alpha = 0.0
        
        self.center = end_point
        self.transform = CGAffineTransformMakeRotation(after_angle)
      }, completion:-> finished {
        darken_view.removeFromSuperview
        unload_back
      })
  	})
  end
end