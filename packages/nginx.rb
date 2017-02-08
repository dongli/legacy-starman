module STARMAN
  class Nginx < Package
    url 'https://nginx.org/download/nginx-1.10.3.tar.gz'
    sha256 '75020f1364cac459cb733c4e1caed2d00376e40ea05588fb8793076a4c69dd90'
    version '1.10.3'

    label :compiler_agnostic

    option 'with-passenger', {
      desc: 'Compile with support for Phusion Passenger module.',
      accept_value: { boolean: false }
    }
    option 'with-webdav', {
      desc: 'Compile with support for WebDAV module',
      accept_value: { boolean: true }
    }
    option 'with-http2', {
      desc: 'Compile with support for HTTP/2 module.',
      accept_value: { boolean: true }
    }
    option 'with-gunzip', {
      desc: 'Compile with support for gunzip module.',
      accept_value: { boolean: true }
    }
    option 'worker-processes', {
      desc: 'Define the number of worker processes.',
      accept_value: { string: 'auto' },
      extra: { profile: false }
    }
    option 'worker-connections', {
      desc: 'Sets the maximum number of simultaneous connections that can be opened by a worker process.',
      accept_value: { string: 1024 },
      extra: { profile: false }
    }

    depends_on :openssl
    depends_on :pcre
    depends_on :zlib

    def install
      inreplace 'conf/nginx.conf', {
        'listen       80;' => 'listen       8080;',
        "    #}\n\n}" => "    #}\n    include servers/*;\n}"
      }
      args = %W[
        --prefix=#{prefix}
        --with-http_ssl_module
        --with-pcre
        --sbin-path=#{bin}/nginx
        --with-cc-opt='-I#{Openssl.inc} -I#{Pcre.inc} -I#{Zlib.inc}'
        --with-ld-opt='-L#{Openssl.lib} -Wl,-rpath,#{Openssl.lib} -L#{Pcre.lib} -L#{Zlib.lib}'
        --conf-path=#{persist}/etc/nginx/nginx.conf
        --pid-path=#{var}/run/nginx.pid
        --lock-path=#{var}/run/nginx.lock
        --http-client-body-temp-path=#{var}/run/nginx/client_body_temp
        --http-proxy-temp-path=#{var}/run/nginx/proxy_temp
        --http-fastcgi-temp-path=#{var}/run/nginx/fastcgi_temp
        --http-uwsgi-temp-path=#{var}/run/nginx/uwsgi_temp
        --http-scgi-temp-path=#{var}/run/nginx/scgi_temp
        --http-log-path=#{var}/log/nginx/access.log
        --error-log-path=#{var}/log/nginx/error.log
        --with-http_gzip_static_module
        --with-ipv6
      ]
      args << '--with-http_dav_module' if with_webdav?
      args << '--with-http_v2_module' if with_http2?
      args << '--with-http_gunzip_module' if with_gunzip?
      run './configure', *args
      run 'make', 'install'
      mkdir_p man
      cp 'man/nginx.8', man
    end

    def post_install
      mkdir_p "#{persist}/etc/nginx/servers"
      mkdir_p "#{var}/run/nginx"
    end

    def start
      return if status
      inreplace "#{persist}/etc/nginx/nginx.conf", {
        /worker_processes.*/ => "worker_processes #{worker_processes};",
        /worker_connections.*/ => "worker_connections #{worker_connections};"
      }
      res = run "#{bin}/nginx", :skip_error, :capture_output
      unless $?.success?
        if res =~ /Permission denied/
          CLI.report_warning "You need root privilege to start #{CLI.blue 'nginx'}!"
          run 'sudo', "#{bin}/nginx", :screen_output
        end
      end
    end

    def status
      process_running? `cat #{var}/run/nginx.pid` if File.exist? "#{var}/run/nginx.pid"
    end

    def stop
      res = run "#{bin}/nginx", '-s stop', :skip_error, :capture_output
      unless $?.success?
        if res =~ /Operation not permitted/
          CLI.report_warning "You need root privilege to stop #{CLI.blue 'nginx'}!"
          run 'sudo', "#{bin}/nginx", '-s stop', :screen_output
        end
      end
    end
  end
end
