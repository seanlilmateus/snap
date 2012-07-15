SESSION_ID = "Snap!"
QuitReasonNoNetwork = 0         	# no Wi-Fi or Bluetooth
QuitReasonConnectionDropped = 1  	# communication failure with server
QuitReasonUserQuit = 2           	# the user terminated the connection
QuitReasonServerQuit =3        		# the server quit the game (on purpose)

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
