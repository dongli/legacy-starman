module STARMAN
  class Tbb < Package
    homepage 'https://www.threadingbuildingblocks.org/'
    url 'https://www.threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb44_20160526oss_src_0.tgz'
    sha256 '7bafdcc3bca3aa1acc03da4735aefd6a4ddf2eceec983202319d0a911da1f0d1'
    version '4.4-20160526'
    language :cxx

    option 'with-python2', {
      desc: 'Build with Python 2 support.',
      accept_value: { boolean: false }
    }

    option 'with-python3', {
      desc: 'Build with Python 3 support.',
      accept_value: { boolean: false }
    }

    depends_on :swig
    depends_on :python2 if with_python2?
    depends_on :python3 if with_python3?

    def install
      CompilerStore.no_optimization
      args = %W[
        tbb_build_prefix=BUILDPREFIX
        compiler=#{CompilerStore.compiler(:c).command.basename}
        stdver=c++11
      ]
      args << 'stdlib=libc++' if OS.mac? and CompilerStore.compiler(:cxx).vendor == :llvm
      run 'make', *args
      mkdir_p [lib, inc], force: true
      cp Dir.glob("build/BUILDPREFIX_release/*.#{OS.soname}"), lib
      cp_r 'include/tbb', inc
    end
  end
end
