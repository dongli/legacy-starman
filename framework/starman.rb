require 'requires'

$LOAD_PATH << "#{ENV['STARMAN_ROOT']}/packages"

STARMAN::OS.init
STARMAN::CommandLine.run
STARMAN::ConfigStore.init
STARMAN::System::Shell.init
STARMAN::ConfigStore.run
STARMAN::Storage.init :bintray
STARMAN::PackageLoader.run
STARMAN::RemoteServer.init

STARMAN::System::Xcode.init if STARMAN::OS.mac?

if STARMAN::CompilerStore.active_compiler_set
  STARMAN::DirtyWorks.handle_absent_compiler STARMAN::CommandLine.packages
end

STARMAN::CommandLine.check_invalid_options

def clean
  FileUtils.rm_f "#{STARMAN::ConfigStore.package_root}/stdout.#{Process.pid}"
  FileUtils.rm_f "#{STARMAN::ConfigStore.package_root}/stderr.#{Process.pid}"
  STARMAN::System::Xcode.final if STARMAN::OS.mac?
end

Kernel.trap('INT') do
  print "GOOD BYE!\n"
  clean
  exit
end

# FIXME: This may not be right.
at_exit { clean if $! }
