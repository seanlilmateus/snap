module PlayerPosition
  Bottom = :buttom
  Left = :left
  Top = :top
  Right = :right
end

class Player
  attr_accessor :position, :name, :peer_id
  def dealloc
  	NSLog("dealloc %@", self) if DEBUG
  end
  
  def description
    "peer_id = #{@peer_id}, name = #{@name}, position = #{@position}, #{super}"
  end
end