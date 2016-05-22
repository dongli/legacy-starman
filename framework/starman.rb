require 'byebug'
require 'forwardable'
require 'uri'
require 'digest'
require 'yaml'

require 'extends/string'
require 'extends/fileutils'

require 'utils/cli'
require 'utils/option_spec'
require 'utils/version_spec'
require 'utils/helpers'

require 'system/command/helpers'
require 'system/command/pkgconfig'
require 'system/command/curl'
require 'system/command/cd'
require 'system/command/tar'
require 'system/command/decompress'

require 'system/shell/bash'

require 'system/os/os_spec'
require 'system/os/os_dsl'
require 'system/os/os'
require 'system/os/mac'

require 'compiler/compiler_spec'
require 'compiler/compiler_dsl'
require 'compiler/compiler'
require 'compiler/gcc_compiler'
require 'compiler/clang_compiler'
require 'compiler/intel_compiler'
require 'compiler/pgi_compiler'
require 'compiler/compiler_set'
require 'compiler/compiler_store'

require 'command/config'
require 'command/install'
require 'command/upload'
require 'command/command_line'
require 'command/config_store'

require 'package/package_spec'
require 'package/package_dsl'
require 'package/package_params'
require 'package/package_default_methods'
require 'package/package'
require 'package/package_loader'
require 'package/package_downloader'
require 'package/package_installer'
require 'package/package_binary'

require 'storage/qiniu_adapter'
require 'storage/storage'

$LOAD_PATH << "#{ENV['STARMAN_ROOT']}/packages"

STARMAN::OS.init
STARMAN::CommandLine.run
STARMAN::PackageLoader.run
STARMAN::CommandLine.check_options
STARMAN::System::Bash.init
STARMAN::ConfigStore.init
STARMAN::ConfigStore.run
STARMAN::Storage.init :qiniu

Kernel.trap('INT') do
  print "GOOD BYE!\n"
  STARMAN::System::Bash.final
  exit
end

at_exit {
  if $!
    STARMAN::System::Bash.final
  end
}
