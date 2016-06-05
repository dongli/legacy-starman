module STARMAN
  class Postgresql < Package
    homepage 'https://www.postgresql.org/'
    url 'https://ftp.postgresql.org/pub/source/v9.5.3/postgresql-9.5.3.tar.bz2'
    sha256 '7385c01dc58acba8d7ac4e6ad42782bd7c0b59272862a3a3d5fe378d4503a0b4'
    version '9.5.3'

    label :compiler_agnostic

    option 'with-perl', { desc: 'Build with Perl support', accept_value: { boolean: false } }
    option 'with-tcl', { desc: 'Build with Tcl support', accept_value: { boolean: false } }
    option 'with-dtrace', { desc: 'Build with DTrace support', accept_value: { boolean: false } }
    option 'admin-user', { desc: 'Set admin user name.', accept_value: { string: 'postgres' } }

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
        --with-bonjour
        --with-gssapi
        --with-ldap
        --with-openssl
        --with-pam
        --with-libxml
        --with-libxslt
        --with-uuid=e2fs
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
