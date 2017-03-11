module STARMAN
  class Python2 < Package
    homepage 'https://www.python.org'
    url 'https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz'
    sha256 '3cb522d17463dfa69a155ab18cffa399b358c966c0363d6c8b5b3bf1384da4b6'
    version '2.7.12'

    label :compiler_agnostic

    option 'with-berkeleydb4', {
      desc: 'Build Berkeleydb4 support.',
      accept_value: { boolean: false }
    }

    option 'with-sqlite', {
      desc: 'Build Sqlite support.',
      accept_value: { boolean: false }
    }

    depends_on :berkeleydb4 if with_berkeleydb4?
    depends_on :bzip2
    depends_on :readline
    depends_on :openssl
    depends_on :sqlite if with_sqlite?
    depends_on :xz
    depends_on :zlib

    resource :setuptools do
      url 'https://files.pythonhosted.org/packages/9f/7c/0a33c528164f1b7ff8cf0684cf88c2e733c8ae0119ceca4a3955c7fc059d/setuptools-23.1.0.tar.gz'
      sha256 '4e269d36ba2313e6236f384b36eb97b3433cf99a16b94c74cca7eee2b311f2be'
    end

    resource :pip do
      url 'https://files.pythonhosted.org/packages/e7/a8/7556133689add8d1a54c0b14aeff0acb03c64707ce100ecd53934da1aa13/pip-8.1.2.tar.gz'
    sha256 '4d24b03ffa67638a3fa931c09fd9e0273ffa904e95ebebe7d4b1a54c93d7b732'
    end

    resource :wheel do
      url 'https://files.pythonhosted.org/packages/c9/1d/bd19e691fd4cfe908c76c429fe6e4436c9e83583c4414b54f6c85471954a/wheel-0.29.0.tar.gz'
    sha256 '1ebb8ad7e26b448e9caa4773d2357849bf80ff9e313964bcaf79cbf0201a1648'
    end

    patch :DATA if OS.mac?

    def install
      # Unset these so that installing pip and setuptools puts them where we want
      # and not into some other Python the user has installed.
      ENV['PYTHONHOME'] = nil
      ENV['PYTHONPATH'] = nil
      ENV['LC_CTYPE'] = 'en_US.UTF-8'

      System::Shell.append 'LDFLAGS', "-Wl,-rpath,#{Openssl.lib}"

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

      if OS.mac?
        # Matplotlib needs Python to be installed as framework for using macosx backend.
        args << "--enable-framework=#{frameworks}"
        args << "MACOSX_DEPLOYMENT_TARGET=#{OS.version.major_minor}"
      else
        args << '--enable-shared'
      end

      inreplace 'setup.py', {
        "do_readline = self.compiler.find_library_file(lib_dirs, 'readline')" => "do_readline = '#{Readline.prefix}/libhistory.dylib'",
        '/usr/local/ssl' => Openssl.prefix
      }
      if with_berkeleydb4?
        inreplace 'setup.py', {
          '/usr/include/db4' => Berkeleydb4.inc
        }
      end
      if with_sqlite?
        inreplace 'setup.py', {
          'sqlite_defines.append(("SQLITE_OMIT_LOAD_EXTENSION", "1"))' => 'pass',
          "sqlite_inc_paths = [ '/usr/include'" => "sqlite_inc_paths = [ '#{Sqlite.inc}'"
        }
      end

      run './configure', *args
      inreplace 'pyconfig.h', '/* #undef HAVE_BROKEN_POLL */', '#define HAVE_BROKEN_POLL 1'
      inreplace 'Modules/selectmodule.c', '#undef HAVE_BROKEN_POLL', ''
      inreplace 'Makefile', 'CONFIGURE_LDFLAGS=', "CONFIGURE_LDFLAGS= -L#{Bzip2.lib} -L#{Zlib.lib} -L#{Readline.lib} -L#{Xz.lib}"

      run 'make'
      run 'make', 'install', "PYTHONAPPSDIR=#{prefix}"
      run 'make', 'quicktest' if not skip_test?

      install_resource :setuptools, "#{libexec}/setuptools", strip_leading_dirs: 1
      install_resource :pip, "#{libexec}/pip", strip_leading_dirs: 1
      install_resource :wheel, "#{libexec}/wheel", strip_leading_dirs: 1
    end

    def post_install
      System::Shell.append OS.ld_library_path, lib, separator: ':'
      # Install modules into persistent directory.
      site_packages = "#{persist}/lib/python2.7/site-packages"
      mkdir_p site_packages
      rm_rf "#{lib}/python2.7/site-packages"
      ln_sf site_packages, "#{lib}/python2.7/"
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
      work_in "#{libexec}/setuptools" do run "#{bin}/python", *setup_args end
      work_in "#{libexec}/pip" do run "#{bin}/python", *setup_args end
      work_in "#{libexec}/wheel" do run "#{bin}/python", *setup_args end
    end
  end
end

__END__
diff --git a/Include/pyport.h b/Include/pyport.h
--- a/Include/pyport.h
+++ b/Include/pyport.h
@@ -699,6 +699,12 @@
 #endif

 #ifdef _PY_PORT_CTYPE_UTF8_ISSUE
+#ifndef __cplusplus
+   /* The workaround below is unsafe in C++ because
+    * the <locale> defines these symbols as real functions,
+    * with a slightly different signature.
+    * See issue #10910
+    */
 #include <ctype.h>
 #include <wctype.h>
 #undef isalnum
@@ -716,6 +722,7 @@
 #undef toupper
 #define toupper(c) towupper(btowc(c))
 #endif
+#endif


 /* Declarations for symbol visibility.
