class Card
  include TheGame::Suit
    
  attr_reader :suit, :value
  attr_accessor :is_turned_over
  
  def initWithSuit(suit, value:value)
  	NSAssert(value >= CardAce && value <= CardKing, "Invalid card value")
    init.tap do
      @suit = suit
      @value = value
    end
  end
  def dealloc
  	NSLog("dealloc %@", self) if DEBUG
  end
end