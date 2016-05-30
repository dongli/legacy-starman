module STARMAN
  module PackageHelpers
    def self.included base
      base.extend self
    end

    def needs_build?
      return true if not CommandLine.options[:'local-build'] or CommandLine.options[:'local-build'].value
      not PackageBinary.has? self.group_master || self
    end

    def std_cmake_args
      %W[
        -DCMAKE_C_FLAGS_RELEASE=-DNDEBUG
        -DCMAKE_CXX_FLAGS_RELEASE=-DNDEBUG
        -DCMAKE_INSTALL_PREFIX=#{prefix}
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_FIND_FRAMEWORK=LAST
        -DCMAKE_VERBOSE_MAKEFILE=ON
        -Wno-dev
      ]
    end
  end
end
