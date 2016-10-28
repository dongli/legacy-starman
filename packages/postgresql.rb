module STARMAN
  class Postgresql < Package
    homepage 'https://www.postgresql.org/'
    url 'https://ftp.postgresql.org/pub/source/v9.6.0/postgresql-9.6.0.tar.bz2'
    sha256 '3b5fe9634b80a4511aac1832a087586a7caa8c3413619562bdda009a015863ce'
    version '9.6.0'

    label :compiler_agnostic

    compatible_with '10.11' if OS.mac? and OS.version =~ '10.12'

    option 'with-perl', { desc: 'Build with Perl support', accept_value: { boolean: false } }
    option 'with-tcl', { desc: 'Build with Tcl support', accept_value: { boolean: false } }
    option 'with-dtrace', { desc: 'Build with DTrace support', accept_value: { boolean: false } }
    option 'admin-user', { desc: 'Set admin user name.', accept_value: { string: 'postgres' }, extra: { profile: false } }
    option 'port', { desc: 'Set the default port number.', accept_value: { string: '5432' } }

    depends_on :openssl
    depends_on :readline
    depends_on :libxml2
    depends_on :uuid if not OS.mac?
    depends_on :zlib

    def cluster_path
      "#{persist}/data"
    end

    def install
      args = %W[
        --disable-debug
        --prefix=#{prefix}
        --localstatedir=#{persist}
        --enable-thread-safety
        --with-pgport=#{port}
        --with-bonjour
        --with-gssapi
        --with-ldap
        --with-openssl
        --with-pam
        --with-libxml
        --with-libxslt
        --with-uuid=e2fs
        --without-tcl
      ]

      run './configure', *args
      run 'make'
      run 'make', 'install-world'
    end

    def post_install
      if not OS.check_user admin_user
        CLI.report_notice "Create system user #{CLI.blue admin_user}."
        OS.create_user(admin_user, :hide_login)
      end
      if not Dir.exist? cluster_path
        CLI.report_notice "Initialize database cluster in #{cluster_path}."
        run "sudo mkdir -p #{cluster_path}"
        OS.change_owner persist, admin_user
        OS.change_owner cluster_path, admin_user
        run "sudo -u #{admin_user} #{bin}/initdb --pwprompt -U #{admin_user} -D #{cluster_path} -E UTF8"
      end
    end

    def start
      cmd = "#{bin}/pg_ctl start -D #{cluster_path} -l #{persist}/postgres.log"
      if ENV['USER'] != admin_user
        run "sudo -u #{admin_user} #{cmd}", :screen_output, :skip_error
      else
        run cmd, :skip_error
      end
    end

    def stop
      cmd = "#{bin}/pg_ctl stop -D #{cluster_path}"
      if ENV['USER'] != admin_user
        run "sudo -u #{admin_user} #{cmd}", :screen_output, :skip_error
      else
        run cmd, :skip_error
      end
    end

    def status
      cmd = "#{bin}/pg_ctl status -D #{cluster_path}"
      if ENV['USER'] != admin_user
        run "sudo -u #{admin_user} #{cmd}", :screen_output, :skip_error
      else
        run cmd, :skip_error
      end
      $?.success? ? :on : :off
    end
  end
end
