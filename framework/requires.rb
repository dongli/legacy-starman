begin
  require 'byebug'
  require 'readline'
  require 'net/http'
rescue LoadError
end

require 'forwardable'
require 'uri'
require 'digest'
require 'yaml'
require 'json'
require 'pathname'

require 'extends/string'
require 'extends/fileutils'

require 'utils/cli'
require 'utils/option_spec'
require 'utils/version_spec'
require 'utils/helpers'
require 'utils/dirty_works'
require 'utils/maintainer'

require 'system/command/helpers'
require 'system/command/pkgconfig'
require 'system/command/curl'
require 'system/command/patch'
require 'system/command/compression'
require 'system/command/run'

require 'system/shell/bash'
require 'system/shell/shell'

require 'system/os/os_spec'
require 'system/os/os_dsl'
require 'system/os/os'
require 'system/os/mac'
require 'system/os/linux'
require 'system/os/ubuntu'
require 'system/os/redhat'
require 'system/os/fedora'
require 'system/os/centos'
require 'system/os/suse'
require 'system/os/scientific_linux'
require 'system/os/aix'

require 'system/ide/xcode'

require 'system/server/remote_server'

require 'compiler/compiler_spec'
require 'compiler/compiler_dsl'
require 'compiler/compiler'
require 'compiler/gcc_compiler'
require 'compiler/clang_compiler'
require 'compiler/intel_compiler'
require 'compiler/pgi_compiler'
require 'compiler/compiler_set'
require 'compiler/compiler_store'

require 'command/clean'
require 'command/config'
require 'command/download'
require 'command/edit'
require 'command/deploy'
require 'command/install'
require 'command/remove'
require 'command/upload'
require 'command/update'
require 'command/shell'
require 'command/show'
require 'command/start'
require 'command/stop'
require 'command/status'
require 'command/command_line'
require 'command/config_store'

require 'package/package_spec'
require 'package/package_dsl'
require 'package/package_params'
require 'package/package_default_methods'
require 'package/package_shortcuts'
require 'package/package_profile'
require 'package/package_helpers'
require 'package/package_resource'
require 'package/package'
require 'package/package_alias'
require 'package/package_loader'
require 'package/package_downloader'
require 'package/package_installer'
require 'package/package_uninstaller'
require 'package/package_binary'

require 'storage/bintray_adapter'
require 'storage/qiniu_adapter'
require 'storage/storage'
