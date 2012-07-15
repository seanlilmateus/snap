class PeerCell < UITableViewCell
	def initWithStyle(style, reuseIdentifier:reuse_id)
		super.tap do |cell|
			cell.backgroundView = UIImageView.alloc.initWithImage(UIImage.imageNamed("CellBackground"))
			cell.selectedBackgroundView = UIImageView.alloc.initWithImage(UIImage.imageNamed("CellBackgroundSelected"))

			cell.textLabel.font = GameTheme.snap_font(24.0)
			cell.textLabel.textColor = UIColor.colorWithRed(116/255, green:192/255, blue:97/255, alpha:1.0)
			cell.textLabel.highlightedTextColor = cell.textLabel.textColor
		end
	end	
end