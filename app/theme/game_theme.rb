module GameTheme
  def snap_button(*buttons)
    buttons.each do |button|
      button.titleLabel.font = GameTheme.snap_font(20.0)
      button_image = UIImage.imageNamed("Button").resizableImageWithCapInsets(UIEdgeInsetsMake(0, 15, 0, 15))
      # stretchableImageWithLeftCapWidth(15, topCapHeight:0) we don't use this cause of deprecation
      button.setBackgroundImage(button_image, forState:UIControlStateNormal)
    
      pressed_image = UIImage.imageNamed("ButtonPressed").resizableImageWithCapInsets(UIEdgeInsetsMake(0, 15, 0, 15))
      button.setBackgroundImage(pressed_image, forState:UIControlStateHighlighted)
    end
  end
  
  def snap_font(size=14.0)
    UIFont.fontWithName("Action Man", size:size)
  end
  
  def NSLocalizedString(key, value)
    NSBundle.mainBundle.localizedStringForKey(key, value:value, table:nil)
  end
  
  module_function :snap_font, :snap_button
end

