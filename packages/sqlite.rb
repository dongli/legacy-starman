module STARMAN
  class Sqlite < Package
    homepage 'https://sqlite.org/'
    url 'https://sqlite.org/2016/sqlite-autoconf-3140100.tar.gz'
    sha256 'bc7182476900017becb81565ecea7775d46ab747a97281aa610f4f45881c47a6'
    version '3.14.1'

    label :system_conflict if OS.mac?

    option 'with-rtree', {
      desc: 'Disable the R*Tree index module',
      accept_value: { boolean: true }
    }
    option 'with-fts', {
      desc: 'Enable the FTS3 module',
      accept_value: { boolean: true }
    }
    option 'with-fts5', {
      desc: 'Enable the FTS5 module',
      accept_value: { boolean: false }
    }
    option 'with-secure-delete', {
      desc: 'Defaults secure_delete to on',
      accept_value: { boolean: true }
    }
    option 'with-unlock-notify', {
      desc: 'Enable the unlock notification feature',
      accept_value: { boolean: true }
    }
    option 'with-icu4c', {
      desc: 'Enable the ICU module',
      accept_value: { boolean: true }
    }
    option 'with-functions', {
      desc: 'Enable more math and string functions for SQL queries',
      accept_value: { boolean: true }
    }
    option 'with-dbstat', {
      desc: 'Enable the dbstat virtual table',
      accept_value: { boolean: true }
    }
    option 'with-json1', {
      desc: 'Enable the JSON1 extension',
      accept_value: { boolean: true }
    }
    option 'with-session', {
      desc: 'Enable the session extension',
      accept_value: { boolean: true }
    }

    depends_on :readline
    depends_on :icu4c if with_icu4c?

    resource :functions do
      url 'https://sqlite.org/contrib/download/extension-functions.c?get=25'
      sha256 '991b40fe8b2799edc215f7260b890f14a833512c9d9896aa080891330ffe4052'
    end

    def install
      System::Shell.append 'CPPFLAGS', '-DSQLITE_ENABLE_COLUMN_METADATA=1'
      System::Shell.append 'CPPFLAGS', '-DSQLITE_MAX_VARIABLE_NUMBER=250000'
      System::Shell.append 'CPPFLAGS', '-DSQLITE_ENABLE_RTREE=1' if with_rtree?
      System::Shell.append 'CPPFLAGS', '-DSQLITE_ENABLE_FTS3=1' if with_fts?
      System::Shell.append 'CPPFLAGS', '-DSQLITE_ENABLE_FTS5=1' if with_fts5?
      System::Shell.append 'CPPFLAGS', '-DSQLITE_SECURE_DELETE=1' if with_secure_delete?
      System::Shell.append 'CPPFLAGS', '-DSQLITE_ENABLE_UNLOCK_NOTIFY=1' if with_unlock_notify?
      System::Shell.append 'CPPFLAGS', '-DSQLITE_ENABLE_DBSTAT_VTAB=1' if with_dbstat?
      System::Shell.append 'CPPFLAGS', '-DSQLITE_ENABLE_JSON1=1' if with_json1?
      System::Shell.append 'CPPFLAGS', '-DSQLITE_ENABLE_PREUPDATE_HOOK=1 -DSQLITE_ENABLE_SESSION=1' if with_session?

      if with_icu4c?
        System::Shell.append 'LDFLAGS', `#{Icu4c.bin}/icu-config --ldflags`.chomp
        System::Shell.append 'CPPFLAGS', `#{Icu4c.bin}/icu-config --cppflags`.chomp
        System::Shell.append 'CPPFLAGS', '-DSQLITE_ENABLE_ICU=1'
      end

      args = %W[
        --prefix=#{prefix}
        --datarootdir=#{persist}
        --disable-dependency-tracking
        --enable-dynamic-extensions
      ]
      run './configure', *args
      run 'make', 'install'

      if with_functions?
        install_resource :functions, '.', plain_file: true
        args = %W[
          -fno-common
          -dynamiclib
          extension-functions.c
          -o libsqlitefunctions.#{OS.soname}
        ]
        run CompilerStore.compiler(:c).command, *args
        cp "libsqlitefunctions.#{OS.soname}", lib
      end
    end
  end
end
