class Player
  attr_accessor :position, :name, :peer_id, :received_response, :games_won
  def init
    super.tap { @games_won = 0 }
  end
  
  def dealloc
  	NSLog("dealloc %@", self) if DEBUG
  end
  
  def description
    "peer_id = #{@peer_id}, name = #{@name}, position = #{@position}, #{super}"
  end
end