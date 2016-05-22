require 'requires'

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
