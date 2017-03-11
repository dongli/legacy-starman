module STARMAN
  class Python3 < Package
    homepage 'https://www.python.org'
    url 'https://www.python.org/ftp/python/3.6.0/Python-3.6.0.tgz'
    sha256 'aa472515800d25a3739833f76ca3735d9f4b2fe77c3cb21f69275e0cce30cb2b'
    version '3.6.0'

    label :compiler_agnostic

    option 'with-sqlite', {
      desc: 'Build Sqlite support.',
      accept_value: { boolean: false }
    }

    if OS.mac? and OS.version =~ '10.12'
      patch do
        url 'https://bugs.python.org/file44575/issue28087.patch'
        sha256 '41edcb22b529d68103cfc995041340089fd7cd08bc01168b8cfc7eef24bde787'
      end
    end

    depends_on :bzip2
    depends_on :pkgconfig if needs_build?
    depends_on :readline
    depends_on :sqlite if with_sqlite?
    depends_on :openssl
    depends_on :unzip if needs_build?
    depends_on :xz
    depends_on :zlib

    resource :setuptools do
      url 'https://github.com/pypa/setuptools/archive/v32.2.0.tar.gz'
      sha256 '664c31e6b3869faf85479a6f095fb2f32bdc35d353fdcfb18309a3fcffbd3592'
      filename 'setuptools-32.2.0.tar.gz'
    end

    resource :pip do
      url 'https://pypi.python.org/packages/11/b6/abcb525026a4be042b486df43905d6893fb04f05aac21c32c638e939e447/pip-9.0.1.tar.gz'
      sha256 '09f243e1a7b461f654c26a725fa373211bb7ff17a9300058b205c61658ca940d'
    end

    resource :wheel do
      url 'https://pypi.python.org/packages/source/w/wheel/wheel-0.29.0.tar.gz'
      sha256 '1ebb8ad7e26b448e9caa4773d2357849bf80ff9e313964bcaf79cbf0201a1648'
    end

    def self.xy
      version.split('.')[0..1].join('.')
    end

    def site_packages
      "#{persist}/lib/python#{Python3.xy}/site-packages"
    end

    def install
      # Unset these so that installing pip and setuptools puts them where we want
      # and not into some other Python the user has installed.
      ENV["PYTHONHOME"] = nil
      ENV["PYTHONPATH"] = nil
      ENV['LC_CTYPE'] = 'en_US.UTF-8'

      System::Shell.append 'LDFLAGS', "-Wl,-rpath,#{Openssl.lib}"

      args = %W[
        --prefix=#{prefix}
        --enable-ipv6
        --without-ensurepip
      ]

      if CompilerStore.compiler(:c).vendor == :gnu
        args << '--disable-toolbox-glue' if OS.mac?
      else
        args << '--without-gcc'
        args << '--with-icc' if CompilerStore.compiler(:c).vendor == :intel
      end

      if OS.mac?
        # Matplotlib needs Python to be installed as framework for using macosx backend.
        args << "--enable-framework=#{frameworks}"
        args << "MACOSX_DEPLOYMENT_TARGET=#{OS.version.major_minor}"
      else
        args << '--enable-shared'
      end

      inreplace 'setup.py', {
        "do_readline = self.compiler.find_library_file(lib_dirs, 'readline')" => "do_readline = '#{Readline.prefix}/libhistory.dylib'",
        '/usr/local/ssl' => Openssl.prefix,
      }
      if with_sqlite?
        inreplace 'setup.py', {
          'sqlite_defines.append(("SQLITE_OMIT_LOAD_EXTENSION", "1"))' => 'pass',
          "sqlite_inc_paths = [ '/usr/include'" => "sqlite_inc_paths = [ '#{Sqlite.inc}'"
        }
      end
      inreplace 'pyconfig.h.in', '#undef HAVE_BROKEN_POLL', '#define HAVE_BROKEN_POLL'
      inreplace 'Modules/selectmodule.c', '#undef HAVE_BROKEN_POLL', ''

      run './configure', *args
      inreplace 'Makefile', 'CONFIGURE_LDFLAGS=', "CONFIGURE_LDFLAGS= -L#{Bzip2.lib} -L#{Zlib.lib} -L#{Readline.lib} -L#{Xz.lib}"
      run 'make'
      run 'make', 'install', "PYTHONAPPSDIR=#{prefix}"
      run 'make', 'frameworkinstallextras', "PYTHONAPPSDIR=#{persist}/share" if OS.mac?
      run 'make', 'quicktest' if not skip_test?

      install_resource :setuptools, "#{libexec}/setuptools", strip_leading_dirs: 1
      install_resource :pip, "#{libexec}/pip", strip_leading_dirs: 1
      install_resource :wheel, "#{libexec}/wheel", strip_leading_dirs: 1
    end

    def post_install
      if OS.mac?
        # Link bin directory.
        rm_rf bin
        ln_sf "#{frameworks}/Python.framework/Versions/Current/bin", prefix
        # Lib is in different place.
        _lib = "#{frameworks}/Python.framework/Versions/Current/lib"
      else
        _lib = lib
      end
      # Install modules into persistent directory.
      mkdir_p site_packages
      rm_rf "#{_lib}/python#{Python3.xy}/site-packages"
      ln_sf site_packages, "#{_lib}/python#{Python3.xy}/"

      rm_rf "#{site_packages}/setuptools*"
      rm_rf "#{site_packages}/distribute*"
      rm_rf "#{site_packages}/pip[-_.][0-9]*"
      rm_rf "#{site_packages}/pip"
      setup_args = ['-s', 'setup.py', '--no-user-cfg', 'install', '--force',
                    '--verbose',
                    '--single-version-externally-managed',
                    '--record=installed.txt',
                    "--install-scripts=#{bin}",
                    "--install-lib=#{site_packages}"]
      System::Shell.append OS.ld_library_path, _lib, separator: ':'
      work_in "#{libexec}/setuptools" do
        run "#{bin}/python3", 'bootstrap.py'
        run "#{bin}/python3", *setup_args
      end
      work_in "#{libexec}/pip" do run "#{bin}/python3", *setup_args end
      work_in "#{libexec}/wheel" do run "#{bin}/python3", *setup_args end

      # Remove pip and easy_install, since python2 installs them too.
      rm_rf "#{bin}/pip"
      rm_rf "#{bin}/easy_install"
      mv "#{bin}/wheel", "#{bin}/wheel3"

      # Install some usefull packages.
      ['ipython'].each do |package|
        run "#{bin}/pip3", 'install', '--upgrade', package
      end
    end
  end
end
