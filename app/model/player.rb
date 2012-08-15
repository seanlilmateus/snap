class Player
  attr_accessor :position, :name, :peer_id, :received_response, :games_won
  attr_reader :closed_cards, :open_cards
  
  def init
    super.tap do 
      @games_won = 0
      @closed_cards = Stack.alloc.init
      @open_cards = Stack.alloc.init
    end
  end
  
  def dealloc
  	NSLog("dealloc %@", self) if DEBUG
  end
  
  def description
    "peer_id = #{@peer_id}, name = #{@name}, position = #{@position}, #{super}"
  end
  
  def turn_over_top_card
  	NSAssert(@closed_cards.cards_count > 0, "No more cards")
    card = @closed_cards.top_most_card
    card.is_turned_over = true
    @open_cards.add_card_to_top(card)
    @closed_cards.remove_top_most_card
    card
  end
end