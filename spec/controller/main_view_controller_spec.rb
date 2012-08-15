describe "The Main view controller" do
  tests MainViewController#, :id => 'main'
  after { rotate_device :to => :portrait }
  
  it "does have 3 buttons" do
    buttons = views(UIButton)
    buttons.count.should == 3
    buttons.first.currentTitle.should == 'Host Game'
  end
  
  it "does have 9 images views" do
    image_views = views(UIImageView)
    image_views.count.should == 9
  end
  
  # it "taps buttons" do
  #   tap "Join Game"
  #   #controller.buttonTapped.currentTitle.should == "Join Game"
  # end
end