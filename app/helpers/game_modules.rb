SESSION_ID = "Snap!"
QuitReasonNoNetwork = 0           # no Wi-Fi or Bluetooth
QuitReasonConnectionDropped = 1   # communication failure with server
QuitReasonUserQuit = 2            # the user terminated the connection
QuitReasonServerQuit = 3          # the server quit the game (on purpose)

module Kernel
  def NSLocalizedString(default=nil, key)
    default ||= key
    NSBundle.mainBundle.localizedStringForKey(key, value:default, table:nil)
  end

  def NSAssert(condition, message ="Assertion on failed")
    abort("#{caller}: #{message}") unless condition
  end
end

module TheGame
  module Theme
    class << self
      def snap_button(*buttons)
        buttons.each do |button|
          button.titleLabel.font = snap_font(20.0)
          button_image = UIImage.imageNamed("Button").resizableImageWithCapInsets(UIEdgeInsetsMake(0, 15, 0, 15))
          # stretchableImageWithLeftCapWidth(15, topCapHeight:0) we don't use this because of deprecation
          button.setBackgroundImage(button_image, forState:UIControlStateNormal)
    
          pressed_image = UIImage.imageNamed("ButtonPressed").resizableImageWithCapInsets(UIEdgeInsetsMake(0, 15, 0, 15))
          button.setBackgroundImage(pressed_image, forState:UIControlStateHighlighted)
        end
      end
  
      def snap_font(size=14.0)
        UIFont.fontWithName("Action Man", size:size)
      end
    end
  end

  module ServerState
    ServerStateIdle = 0
    ServerStateAcceptingConnections = 1
    ServerStateIgnoringNewConnections = 2
  end

  module ClientState
    ClientStateIdle = 0
    ClientStateSearchingForServers = 1
    ClientStateConnecting = 2
    ClientStateConnected = 3
  end

  module State
    WaitingForSignIn = 0
    WaitingForReady = 1
    Dealing = 2
    Playing = 3
    GameOver = 4
    Quitting = 5
  end

  module PlayerPosition
    Bottom = 0
    Left = 1
    Top = 2
    Right = 3
  end

  module SNAPPacketType
    PACKET_HEADER_SIZE = 10
    SignInRequest = 0x64      # server to client
    SignInResponse = 0x65     # client to server
  
    ServerReady = 0x66        # server to client
    ClientReady = 0x67        # client to server
    
    DealCards = 0x68          # server to client
    ClientDealtCards = 0x69   # client to server
    
    ActivatePlayer = 0x6A     # server to client
    ClientTurnedCard = 0x6B   # client to server
    
    PlayerShouldSnap = 0x6C   # client to server
    PlayerCalledSnap = 0x6D   # server to client
    
    OtherClientQuit = 0x6E    # server to client
    ServerQuit = 0x70         # server to client
    ClientQuit = 0x71         # server to client
  end
  
  module Suit
  	Clubs    = 0
  	Diamonds = 1
  	Hearts   = 2
  	Spades   = 3
    
    CardAce    = 1
    CardJack   = 11
    CardQueen  = 12
    CardKing   = 13
  end
  
  class << self
    def ntohl(x)
      [x].pack('N').unpack('L').first
    end
 
    def ntohs(x)
      [x].pack('n').unpack('S').first
    end

    def htonl(h)
      [h].pack("L").unpack("N")[0]
    end

    def htons(h)
      [h].pack("S").unpack("n")[0]
    end
  end
end


