module STARMAN
  class Postgresql < Package
    homepage 'https://www.postgresql.org/'
    url 'https://ftp.postgresql.org/pub/source/v9.6.0/postgresql-9.6.0.tar.bz2'
    sha256 '3b5fe9634b80a4511aac1832a087586a7caa8c3413619562bdda009a015863ce'
    version '9.6.0'

    label :compiler_agnostic

    option 'with-perl', { desc: 'Build with Perl support', accept_value: { boolean: false } }
    option 'with-tcl', { desc: 'Build with Tcl support', accept_value: { boolean: false } }
    option 'with-dtrace', { desc: 'Build with DTrace support', accept_value: { boolean: false } }
    option 'admin-user', { desc: 'Set admin user name.', accept_value: { string: 'postgres' }, extra: { profile: false } }
    option 'port', { desc: 'Set the default port number.', accept_value: { string: '5432' } }
    option 'data-root', { desc: 'Set data cluster root.', accept_value: { string: "#{persist}/data" }, extra: { profile: false } }

    depends_on :libxml2
    depends_on :openssl
    depends_on :readline
    depends_on :zlib
    if not OS.mac?
      depends_on :krb5
      depends_on :libxslt
      depends_on :openldap
      depends_on :openpam
      depends_on :termcap
      depends_on :uuid
    end

    def install
      args = %W[
        --disable-debug
        --prefix=#{prefix}
        --localstatedir=#{persist}
        --enable-thread-safety
        --enable-rpath
        --with-pgport=#{port}
        --with-gssapi
        --with-ldap
        --with-openssl
        --with-pam
        --with-libxml
        --with-libxslt
        --with-uuid=#{OS.mac? ? 'e2fs' : 'ossp'}
        --without-tcl
        --with-readline
      ]
      args << '--with-bonjour' if OS.mac?
      cppflags = ["-I#{Readline.inc}", "-I#{Openssl.inc}", "-I#{Zlib.inc}"]
      ldflags = ["-L#{Readline.lib}", "-L#{Openssl.lib}", "-L#{Zlib.lib}"]
      if not OS.mac?
        cppflags << "-I#{Termcap.inc}"; ldflags << "-L#{Termcap.lib}"
        cppflags << "-I#{Krb5.inc}"; ldflags << "-L#{Krb5.lib}"
        cppflags << "-I#{Openpam.inc}"; ldflags << "-L#{Openpam.lib}"
        cppflags << "-I#{Libxslt.inc}"; ldflags << "-L#{Libxslt.lib}"
        cppflags << "-I#{Openldap.inc}"; ldflags << "-L#{Openldap.lib}"
        cppflags << "-I#{Uuid.inc}"; ldflags << "-L#{Uuid.lib}"
      end
      args << "CPPFLAGS='#{cppflags.join(' ')}' LDFLAGS='#{ldflags.join(' ')}'"

      run './configure', *args
      run 'make'
      run 'make', 'install-world'
    end

    def post_install
      unless OS.check_user admin_user
        CLI.report_notice "Create system user #{CLI.blue admin_user}."
        OS.create_user(admin_user, :hide_login)
      end
      unless Dir.exist? persist
        mkdir persist
        OS.change_owner persist, admin_user
      end
      unless Dir.exist? data_root
        CLI.report_notice "Initialize database cluster in #{data_root}."
        run 'sudo', 'mkdir', "-p #{data_root}"
        OS.change_owner data_root, admin_user
        run 'sudo', "-u #{admin_user}", "#{bin}/initdb", '--pwprompt',
          "-U #{admin_user}", "-D #{data_root}", '-E UTF8', :preserve_ld_library_path
      end
    end

    def start
      cmd = "#{bin}/pg_ctl start -D #{data_root} -l #{persist}/postgres.log"
      if ENV['USER'] != admin_user
        run 'sudo', "-u #{admin_user}", cmd, :screen_output, :skip_error, :preserve_ld_library_path
      else
        run cmd, :skip_error
      end
    end

    def stop
      cmd = "#{bin}/pg_ctl stop -D #{data_root}"
      if ENV['USER'] != admin_user
        run 'sudo', "-u #{admin_user}", cmd, :screen_output, :skip_error, :preserve_ld_library_path
      else
        run cmd, :skip_error
      end
    end

    def status
      cmd = "#{bin}/pg_ctl status -D #{data_root}"
      if ENV['USER'] != admin_user
        run 'sudo', "-u #{admin_user}", cmd, :screen_output, :skip_error, :preserve_ld_library_path
      else
        run cmd, :skip_error
      end
      $?.success? ? :on : :off
    end
  end
end
