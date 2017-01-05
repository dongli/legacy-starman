module STARMAN
  class Erlang < Package
    url 'https://github.com/erlang/otp/archive/OTP-19.2.tar.gz'
    sha256 'c6adbc82a45baa49bf9f5b524089da480dd27113c51b3d147aeb196fdb90516b'
    version '19.2'

    label :compiler_agnostic

    option 'without-hipe', {
      desc: 'Disable building hipe; fails on various macOS systems.',
      accept_value: { boolean: false }
    }
    option 'with-dirty-schedulers', {
      desc: 'Enable experimental dirty schedulers.',
      accept_value: { boolean: false }
    }
    option 'with-java', {
      desc: 'Build jinterface application.',
      accept_value: { boolean: false }
    }
    option 'with-docs', {
      desc: 'Install documentation.',
      accept_value: { boolean: false }
    }

    depends_on :m4
    depends_on :ncurses
    depends_on :openssl
    depends_on :termcap

    if with_docs?
      resource :man do
        url 'https://www.erlang.org/download/otp_doc_man_19.2.tar.gz'
        sha256 '8a76ff3bb40a6d6a1552fa5a4204c8a3c7d99d2ea6f12684f02d038b23ad25cb'
      end

      resource :html do
        url 'https://www.erlang.org/download/otp_doc_html_19.2.tar.gz'
        sha256 'c373c8c1a9fe7433825088684932f3ded76f53d5b8a4d3d2a364263f1f783043'
      end
    end

    def install
      if OS.mac? and OS.version == '10.11'
        ENV['erl_cv_clock_gettime_monotonic_default_resolution'] = 'no'
        ENV['erl_cv_clock_gettime_monotonic_try_find_pthread_compatible'] = 'no'
        ENV['erl_cv_clock_gettime_wall_default_resolution'] = 'no'
      end

      # Unset these so that building wx, kernel, compiler and
      # other modules doesn't fail with an unintelligable error.
      %w[LIBS FLAGS AFLAGS ZFLAGS].each { |k| ENV.delete("ERL_#{k}") }

      args = %W[
        --disable-debug
        --disable-silent-rules
        --prefix=#{prefix}
        --enable-kernel-poll
        --enable-threads
        --enable-sctp
        --enable-dynamic-ssl-lib
        --with-ssl=#{Openssl.prefix}
        --enable-shared-zlib
        --enable-smp-support
        --enable-native-libs
        --with-dynamic-trace=dtrace
      ]
      args << '--enable-darwin-64bit' if OS.mac?
      args << '--enable-dirty-schedulers' if with_dirty_schedulers?
      if without_hipe?
        args << '--disable-hipe'
      else
        args << '--enable-hipe'
      end
      if with_java?
        args << '--with-javac'
      else
        args << '--without-javac'
      end
      run './otp_build', 'autoconf' unless File.exist? 'configure'
      run './configure', *args
      run 'make'
      run 'make', 'install'
    end
  end
end