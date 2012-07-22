class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launch_opts)
    UIApplication.sharedApplication.setStatusBarHidden(true, withAnimation:UIStatusBarAnimationNone)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap do |win|
      win.rootViewController = MainViewController.alloc.initWithNibName("MainViewController", bundle:nil)
      win.makeKeyAndVisible
    end
    application.idleTimerDisabled = true
    true
  end
end
