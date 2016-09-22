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
      url 'https://pypi.python.org/packages/e7/a8/7556133689add8d1a54c0b14aeff0acb03c64707ce100ecd53934da1aa13/pip-8.1.2.tar.gz'
      sha256 '4d24b03ffa67638a3fa931c09fd9e0273ffa904e95ebebe7d4b1a54c93d7b732'
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
        run "#{bin}/pip3", 'uninstall', '-y', package
        run "#{bin}/pip3", 'install', '--upgrade', package
      end
    end
  end
end
