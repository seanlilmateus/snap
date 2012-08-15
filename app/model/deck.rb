class Deck
  include TheGame::Suit
  def init
    super.tap do
      @cards = NSMutableArray.arrayWithCapacity(52)
      setup_cards
    end
  end
  
  def setup_cards
    Clubs.upto(Spades) do |suit|
      CardAce.upto(CardKing) { |value| @cards << Card.alloc.initWithSuit(suit, value:value) }
    end
  end
  
  def remaining_cards
    @cards.count
  end
  
  def shuffle
    @cards.count.times { |x| @cards = @cards.shuffle }
  end
  
  def draw
  	NSAssert(self.remaining_cards > 0, "No more cards in the deck")
    @cards.pop
  end
  
  def dealloc
  	NSLog("dealloc %@", self) if DEBUG
  end
end