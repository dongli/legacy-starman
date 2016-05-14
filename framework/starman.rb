require 'byebug'
require 'forwardable'

require 'cli'
require 'system/command/pkgconfig'

require 'command/install'
require 'command/command_line'

require 'package/package_spec'
require 'package/package_dsl'
require 'package/package_params'
require 'package/package_default_methods'
require 'package/package'
require 'package/package_loader'

$LOAD_PATH << "#{ENV['STARMAN_ROOT']}/packages"

STARMAN::CommandLine.run
STARMAN::PackageLoader.run
STARMAN::CommandLine.check_options
