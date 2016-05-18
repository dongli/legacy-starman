require 'byebug'
require 'forwardable'
require 'uri'
require 'digest'

require 'extends/string'
require 'extends/fileutils'

require 'utils/cli'
require 'utils/option_spec'

require 'system/command/system_command'
require 'system/command/pkgconfig'
require 'system/command/curl'

require 'command/config'
require 'command/install'
require 'command/command_line'
require 'command/config_store'

require 'package/package_spec'
require 'package/package_dsl'
require 'package/package_params'
require 'package/package_default_methods'
require 'package/package'
require 'package/package_loader'
require 'package/package_downloader'

$LOAD_PATH << "#{ENV['STARMAN_ROOT']}/packages"

STARMAN::CommandLine.run
STARMAN::PackageLoader.run
STARMAN::CommandLine.check_options
STARMAN::ConfigStore.init
STARMAN::ConfigStore.run
