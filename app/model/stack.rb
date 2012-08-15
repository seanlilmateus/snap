class Stack
  def init
    super.tap { @cards = NSMutableArray.arrayWithCapacity(26) }
  end
  
  def add_card_to_top(card)
  	NSAssert(!card.nil?, "Card cannot be nil")
  	NSAssert(!@cards.include?(card), "Already have this Card")
    @cards << card
  end
  
  def cards_count
    @cards.count
  end
  
  def array
    @cards.copy
  end
  
  def [](idx)
    @cards[idx]
  end
  
  def add_cards_from_array(array)
    @cards = array.mutableCopy
  end
  
  def top_most_card
    @cards.last
  end
  
  def remove_top_most_card
    @cards.pop
  end
  
  def dealloc
  	NSLog("dealloc %@", self) if DEBUG
  end
end