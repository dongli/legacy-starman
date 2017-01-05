module STARMAN
  class Qt5 < Package
    homepage 'http://www.qt.io/developers/'
    url 'https://mirrors.tuna.tsinghua.edu.cn/qt/archive/qt/5.7/5.7.1/single/qt-everywhere-opensource-src-5.7.1.tar.gz'
    sha256 'c86684203be61ae7b33a6cf33c23ec377f246d697bd9fb737d16f0ad798f89b7'
    version '5.7.1'
    language :cxx

    label :compiler_agnostic

    option 'with-examples', {
      desc: 'Build examples.',
      accept_value: { boolean: false }
    }
    option 'with-qtwebkit', {
      desc: 'Build with QtWebkit module.',
      accept_value: { boolean: false }
    }
    option 'with-docs', {
      desc: 'Build documentation (You can see it online).',
      accept_value: { boolean: false }
    }

    depends_on :dbus
    depends_on :postgresql
    depends_on :icu4c if with_qtwebkit? # FIXME: Check this dependency.

    resource :qtwebkit do
      url 'https://download.qt.io/community_releases/5.7/5.7.0/qtwebkit-opensource-src-5.7.0.tar.gz'
      sha256 '30672ad5b5a12ef8ac1f07408f67713f9eb2e2688df77336047984326c294f74'
    end

    def install
      args = %W[
        -verbose
        -prefix #{prefix}
        -c++std c++11
        -release
        -opensource -confirm-license
        -system-zlib
        -qt-libpng
        -qt-libjpeg
        -qt-freetype
        -qt-pcre
        -nomake tests
        -no-rpath
        -plugin-sql-psql
        -I#{Dbus.lib}/dbus-1.0/include
        -I#{Dbus.inc}/dbus-1.0
        -L#{Dbus.lib}
        -ldbus-1
        -dbus-linked
      ]
      args << '-nomake' << 'examples' if not with_examples?
      args << '-nomake' << 'tests' if skip_test?
      if with_qtwebkit?
        install_resource :qtwebkit, 'qtwebkit', strip_leading_dirs: 1
        inreplace '.gitmodules', /.*status = obsolete\n((\s*)project = WebKit\.pro)/, "\\1\n\\2initrepo = true"
      end

      if OS.mac?
        # Fix errors for Xcode 8.
        System::Xcode.select :xcode_app
        inreplace 'qtbase/configure',
          '/usr/bin/xcrun -find xcrun',
          '/usr/bin/xcrun -find xcodebuild'
        inreplace 'qtbase/mkspecs/features/mac/default_pre.prf',
          'isEmpty($$list($$system("/usr/bin/xcrun -find xcrun 2>/dev/null")))',
          'isEmpty($$list($$system("/usr/bin/xcrun -find xcodebuild 2>/dev/null")))'
      end

      run './configure', *args
      run 'make'
      run 'make', 'install'
      if with_docs?
        run 'make', 'docs'
        run 'make', 'install_docs'
      end
      inreplace "#{prefix}/mkspecs/qconfig.pri",
        /\n# pkgconfig\n(PKG_CONFIG_(SYSROOT_DIR|LIBDIR) = .*\n){2}\n/, "\n"
    end
  end
end
