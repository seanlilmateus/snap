# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Snap!'
  app.prerendered_icon = true
  app.icons = %w{Icon.png Icon@2x.png Icon-72.png Icon-Small.png Icon-Small@2x.png Icon-Small-50.png Icon-72@2x.png Icon-Small-50@2x.png}
  app.identifier = 'de.mateus.snap'

  app.interface_orientations = [:landscape_right, :landscape_left]
  app.frameworks += ["AVFoundation", "GameKit"]
  app.info_plist['UIRequiredDeviceCapabilities'] = ['armv7', 'peer-peer']
  app.info_plist['UILaunchImageFile'] = %w{Default.png Default@2x.png}
  
  app.files_dependencies 'app/app_delegate.rb' => 'app/helpers/game_modules.rb'
  app.files_dependencies 'app/controller/main_view_controller.rb' => 'app/helpers/game_modules.rb'
  app.files_dependencies 'app/controller/host_view_controller.rb' => 'app/helpers/game_modules.rb'
  app.files_dependencies 'app/controller/join_view_controller.rb' => 'app/helpers/game_modules.rb'
  app.files_dependencies 'app/helpers/nsdata_extensions.rb' => 'app/helpers/game_modules.rb'
end
