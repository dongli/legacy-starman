require 'byebug'
require 'forwardable'

require 'cli'

require 'command/install'
require 'command/command_line'

require 'package/package_spec'
require 'package/package_dsl'
require 'package/package_params'
require 'package/package'
require 'package/package_loader'

$LOAD_PATH << "#{ENV['STARMAN_ROOT']}/packages"

STARMAN::PackageLoader.init
