module STARMAN
  class Qt5 < Package
    homepage 'http://www.qt.io/developers/'
    url 'https://download.qt.io/official_releases/qt/5.8/5.8.0/single/qt-everywhere-opensource-src-5.8.0.tar.xz'
    sha256 '0f4c54386d3dbac0606a936a7145cebb7b94b0ca2d29bc001ea49642984824b6'
    version '5.8.0'
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
    depends_on :icu4c if with_qtwebkit? # FIXME: Check this dependency.

    patch do
      url 'https://raw.githubusercontent.com/Homebrew/formula-patches/634a19fb/qt5/QTBUG-57656.patch'
      sha256 'a69fc727f4378dbe0cf05ecf6e633769fe7ee6ea52b1630135a05d5adfa23d87'
    end

    resource :qtwebkit do
      url 'https://download.qt.io/community_releases/5.8/5.8.0-final/qtwebkit-opensource-src-5.8.0.tar.xz'
      sha256 '79ae8660086bf92ffb0008b17566270e6477c8fa0daf9bb3ac29404fb5911bec'
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
      if OS.linux? and CompilerStore.compiler(:cxx).vendor == :intel
        args << '-platform linux-icc-64'
      end
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
    end
  end
end
