module STARMAN
  class Python3 < Package
    homepage 'https://www.python.org'
    url 'https://www.python.org/ftp/python/3.5.2/Python-3.5.2.tgz'
    sha256 '1524b840e42cf3b909e8f8df67c1724012c7dc7f9d076d4feef2d3eff031e8a0'
    version '3.5.2'

    label :compiler_agnostic

    patch do
      url 'https://bugs.python.org/file30805/issue10910-workaround.txt'
      sha256 'c075353337f9ff3ccf8091693d278782fcdff62c113245d8de43c5c7acc57daf'
    end

    if OS.mac? and OS.version =~ '10.12'
      patch do
        url 'https://bugs.python.org/file44575/issue28087.patch'
        sha256 '41edcb22b529d68103cfc995041340089fd7cd08bc01168b8cfc7eef24bde787'
      end
    end

    depends_on :pkgconfig if needs_build?
    depends_on :readline
    depends_on :sqlite
    depends_on :openssl
    depends_on :xz

    resource :setuptools do
      url 'https://files.pythonhosted.org/packages/9f/32/81c324675725d78e7f6da777483a3453611a427db0145dfb878940469692/setuptools-25.2.0.tar.gz'
      sha256 'b2757ddac2c41173140b111e246d200768f6dd314110e1e40661d0ecf9b4d6a6'
    end

    resource :pip do
      url 'https://pypi.python.org/packages/11/b6/abcb525026a4be042b486df43905d6893fb04f05aac21c32c638e939e447/pip-9.0.1.tar.gz'
      sha256 '09f243e1a7b461f654c26a725fa373211bb7ff17a9300058b205c61658ca940d'
    end

    resource :wheel do
      url 'https://pypi.python.org/packages/source/w/wheel/wheel-0.29.0.tar.gz'
      sha256 '1ebb8ad7e26b448e9caa4773d2357849bf80ff9e313964bcaf79cbf0201a1648'
    end

    def site_packages
      "#{persist}/lib/python3.5/site-packages"
    end

    def install
      # Unset these so that installing pip and setuptools puts them where we want
      # and not into some other Python the user has installed.
      ENV["PYTHONHOME"] = nil
      ENV["PYTHONPATH"] = nil

      args = %W[
        --prefix=#{prefix}
        --enable-ipv6
        --without-ensurepip
        --enable-shared
      ]

      if CompilerStore.compiler(:c).vendor == :gnu
        args << '--disable-toolbox-glue' if OS.mac?
      else
        args << '--without-gcc'
        args << '--with-icc' if CompilerStore.compiler(:c).vendor == :intel
      end

      args << "MACOSX_DEPLOYMENT_TARGET=#{OS.version.major_minor}"

      inreplace 'setup.py', {
        "do_readline = self.compiler.find_library_file(lib_dirs, 'readline')" => "do_readline = '#{Readline.prefix}/libhistory.dylib'",
        '/usr/local/ssl' => Openssl.prefix,
        'sqlite_defines.append(("SQLITE_OMIT_LOAD_EXTENSION", "1"))' => 'pass',
        "sqlite_inc_paths = [ '/usr/include'" => "sqlite_inc_paths = [ '#{Sqlite.inc}'"
      }
      inreplace 'pyconfig.h.in', {
        '#undef HAVE_BROKEN_POLL' => '#define HAVE_BROKEN_POLL'
      }
      inreplace 'Modules/selectmodule.c', {
        '#undef HAVE_BROKEN_POLL' => ''
      }

      run './configure', *args

      run 'make'
      run 'make', 'install', "PYTHONAPPSDIR=#{prefix}"
      # run 'make', 'frameworkinstallextras', "PYTHONAPPSDIR=#{persist}/share"
      run 'make', 'quicktest' if not skip_test?

      install_resource :setuptools, "#{libexec}/setuptools", strip_leading_dirs: 1
      install_resource :pip, "#{libexec}/pip", strip_leading_dirs: 1
      install_resource :wheel, "#{libexec}/wheel", strip_leading_dirs: 1
    end

    def post_install
      # Install modules into persistent directory.
      mkdir_p site_packages
      rm_rf "#{lib}/python3.5/site-packages"
      ln_sf site_packages, "#{lib}/python3.5/"

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
      work_in "#{libexec}/setuptools" do run "#{bin}/python3", *setup_args end
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
