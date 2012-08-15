DEBUG = false

class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launch_opts)
    return true if RUBYMOTION_ENV == 'test'
    UIApplication.sharedApplication.setStatusBarHidden(true, withAnimation:UIStatusBarAnimationNone)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap do |win|
      win.rootViewController = MainViewController.alloc.initWithNibName("MainViewController", bundle:nil)
      win.makeKeyAndVisible
    end
    application.idleTimerDisabled = true
    true
  end
end
