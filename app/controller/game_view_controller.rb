class GameViewController < UIViewController
	attr_accessor :center_label, :delegate, :game
	
	def dealloc
		NSLog("dealloc %@", self) if DEBUG
	end

	def viewDidLoad
		super
		@center_label.font = Game::Theme.snap_font(18.0)
	end

	def shouldAutorotateToInterfaceOrientation(interface_orientation)
    	interface_orientation == UIInterfaceOrientationLandscapeRight or interface_orientation == UIInterfaceOrientationLandscapeLeft
  	end

	def exit_action(sender)
		@game.quit_game_with_reason(QuitReasonUserQuit)
	end

	# Game Delegate
	def game(game, didQuitWithReason:reason)
		@delegate.gameViewController(self, didQuitWithReason:reason)
	end

	def gameWaitingForServerReady(game)
		@center_label.text = NSLocalizedString("Waiting for game to start...", "Status text: waiting for server")
	end

	def gameWaitingForClientsReady(game)
		@center_label.text = NSLocalizedString("Waiting for other players...", "Status text: waiting for clients")
	end
end