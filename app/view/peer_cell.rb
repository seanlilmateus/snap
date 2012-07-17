class PeerCell < UITableViewCell
	def initWithStyle(style, reuseIdentifier:reuse_id)
		super.tap do |cell|
			cell.backgroundView = UIImageView.alloc.initWithImage(UIImage.imageNamed("CellBackground"))
			cell.selectedBackgroundView = UIImageView.alloc.initWithImage(UIImage.imageNamed("CellBackgroundSelected"))

			cell.textLabel.font = Game::Theme.snap_font(24.0)
			cell.textLabel.textColor = UIColor.colorWithRed(116/255.0, green:192/255.0, blue:97/255.0, alpha:1.0)
			cell.textLabel.highlightedTextColor = cell.textLabel.textColor
		end
	end	
end