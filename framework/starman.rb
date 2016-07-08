require 'requires'

$LOAD_PATH << "#{ENV['STARMAN_ROOT']}/packages"

STARMAN::OS.init
STARMAN::CommandLine.run
STARMAN::ConfigStore.init
STARMAN::System::Shell.init
STARMAN::ConfigStore.run
STARMAN::PackageLoader.run
STARMAN::Storage.init :qiniu

STARMAN::DirtyWorks.handle_absent_compiler STARMAN::CommandLine.packages

def clean
  STARMAN::System::Shell.final
  FileUtils.rm_f "#{STARMAN::ConfigStore.package_root}/stdout.#{Process.pid}"
  FileUtils.rm_f "#{STARMAN::ConfigStore.package_root}/stderr.#{Process.pid}"
end

Kernel.trap('INT') do
  print "GOOD BYE!\n"
  clean
  exit
end

at_exit { clean if $! }
