require 'byebug'
require 'forwardable'

require 'package/spec'
require 'package/dsl'
require 'package/package'
require 'package/loader'

$LOAD_PATH << "#{ENV['STARMAN_ROOT']}/packages"

STARMAN::PackageLoader.init
