require 'requires'

$LOAD_PATH << "#{ENV['STARMAN_ROOT']}/packages"

STARMAN::OS.init
STARMAN::CommandLine.run
STARMAN::PackageLoader.run
STARMAN::CommandLine.check_options
STARMAN::ConfigStore.init
STARMAN::System::Shell.init
STARMAN::ConfigStore.run
STARMAN::Storage.init :qiniu


################################################################################
# The following codes are really mess! They are just used to handle edge cases.
# Change command line and package options that set build language bindings.
[:c, :cxx, :fortran].each do |language|
  next if STARMAN::CompilerStore.compiler(language)
  STARMAN::CommandLine.packages.each_value do |package|
    if package.languages == [language]
      # The package only provides bindings in this language, we should exclude it.
      STARMAN::CommandLine.packages.each_value do |other_package|
        next if other_package == package
        other_package.dependencies.delete(package.name)
        other_package.slaves.delete(package)
      end
      STARMAN::CommandLine.packages.delete package.name
    end
    next if not package.options[:"with-#{language}"]
    package.options[:"with-#{language}"].check 'false'
  end
  next if not STARMAN::CommandLine.options[:"with-#{language}"]
  STARMAN::CommandLine.options[:"with-#{language}"].check 'false'
end
################################################################################

Kernel.trap('INT') do
  print "GOOD BYE!\n"
  STARMAN::System::Shell.final
  exit
end

at_exit {
  if $!
    STARMAN::System::Shell.final
  end
}
