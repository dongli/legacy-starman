module STARMAN
  class Boost < Package
    homepage 'http://www.boost.org/'
    url 'https://downloads.sourceforge.net/project/boost/boost/1.63.0/boost_1_63_0.tar.bz2'
    sha256 'beae2529f759f6b3bf3f4969a19c2e9d6f0c503edcb2de4a61d1428519fcb3b0'
    version '1.63.0'

    option 'with-mpi', {
      desc: 'Build with parallel support.',
      accept_value: { boolean: false }
    }
    option 'with-single', {
      desc: 'Enable building single-threading variant.',
      accept_value: { boolean: true }
    }
    option 'with-static', {
      desc: 'Enable building static library variant.',
      accept_value: { boolean: false }
    }
    option 'with-python2', {
      desc: 'Enable Python2 bindings.',
      accept_value: { boolean: false }
    }
    option 'with-python3', {
      desc: 'Enable Python3 bindings.',
      accept_value: { boolean: false }
    }

    depends_on :icu4c
    depends_on :mpi if with_mpi?
    depends_on :python2 if with_python2?
    depends_on :python3 if with_python3?

    patch :DATA

    def toolset
      compiler = CompilerStore.compiler(:cxx)
      return @toolset if @toolset
      case compiler.vendor
      when :intel
        if compiler.version <= '11.1'
          CLI.report_error 'Intel compiler is too old to compile Boost! See ' +
            'https://software.intel.com/en-us/articles/boost-1400-compilation-error-while-building-with-intel-compiler/'
        end
        if OS.mac?
          @toolset = 'intel-darwin'
        elsif OS.linux?
          @toolset = 'intel-linux'
        end
      when :gnu
        if OS.mac?
          @toolset = 'darwin'
        elsif OS.linux?
          @toolset = 'gcc'
        end
      when :llvm
        @toolset = 'clang'
      end
      @toolset
    end

    def install
      args = %W[
        --prefix=#{prefix}
        --libdir=#{lib}
        --with-icu=#{Icu4c.prefix}
        --with-toolset=#{toolset}
      ]
      without_libraries = []
      if with_python2?
        args << "--with-python=#{Python2.bin}/python"
      elsif with_python3?
        args << "--with-python=#{Python3.bin}/python3"
      else
        without_libraries << 'python'
      end
      without_libraries << 'mpi' if not with_mpi?
      without_libraries << 'log' if CompilerStore.compiler(:cxx).vendor == :llvm
      args << "--without-libraries=#{without_libraries.join(',')}"
      run './bootstrap.sh', *args
      inreplace 'project-config.jam', {
        "using #{toolset} ;" => "using #{toolset} : : #{CompilerStore.compiler(:cxx).command} ;",
      }

      args = %W[
        --prefix=#{prefix}
        --libdir=#{lib}
        --d2
        --j#{CommandLine.options[:'make-jobs'].value}
        --layout=tagged
        install
      ]
      if with_single?
        args << 'threading=multi,single'
      else
        args << 'threading=multi'
      end
      if with_static?
        args << 'link=shared,static'
      else
        args << 'link=shared'
      end
      args << 'cxxflags=-std=c++11'
      args << 'cxxflags=-stdlib=libc++' << 'linkflags=-stdlib=libc++' if CompilerStore.compiler(:cxx).vendor == :llvm
      run './b2', 'headers'
      run './b2', *args
    end
  end
end

__END__
diff --git a/tools/build/src/tools/python.jam b/tools/build/src/tools/python.jam
index 90377ea..123f66a 100644
--- a/tools/build/src/tools/python.jam
+++ b/tools/build/src/tools/python.jam
@@ -493,6 +493,10 @@ local rule probe ( python-cmd )
                 sys.$(s) = [ SUBST $(output) \\<$(s)=([^$(nl)]+) $1 ] ;
             }
         }
+         # Try to get python abiflags
+        full-cmd = $(python-cmd)" -c \"from sys import abiflags; print(abiflags, end='')\"" ;
+
+        sys.abiflags = [ SHELL $(full-cmd) ] ;
         return $(output) ;
     }
 }
@@ -502,7 +506,7 @@ local rule probe ( python-cmd )
 # have a value based on the information given.
 #
 local rule compute-default-paths ( target-os : version ? : prefix ? :
-    exec-prefix ? )
+    exec-prefix ? : abiflags ? )
 {
     exec-prefix ?= $(prefix) ;
 
@@ -539,7 +543,7 @@ local rule compute-default-paths ( target-os : version ? : prefix ? :
     }
     else
     {
-        includes ?= $(prefix)/include/python$(version) ;
+        includes ?= $(prefix)/include/python$(version)$(abiflags) ;
 
         local lib = $(exec-prefix)/lib ;
         libraries ?= $(lib)/python$(version)/config $(lib) ;
@@ -783,7 +787,7 @@ local rule configure ( version ? : cmd-or-prefix ? : includes * : libraries ? :
                     exec-prefix = $(sys.exec_prefix) ;
 
                     compute-default-paths $(target-os) : $(sys.version) :
-                        $(sys.prefix) : $(sys.exec_prefix) ;
+                        $(sys.prefix) : $(sys.exec_prefix) : $(sys.abiflags) ;
 
                     version = $(sys.version) ;
                     interpreter-cmd ?= $(cmd) ;

