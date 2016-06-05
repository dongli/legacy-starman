module STARMAN
  class Redis < Package
    homepage 'http://redis.io/'
    url 'http://download.redis.io/releases/redis-3.2.0.tar.gz'
    sha256 '989f1af3dc0ac1828fdac48cd6c608f5a32a235046dddf823226f760c0fd8762'
    version '3.2.0'

    label :compiler_agnostic

    option "with-jemalloc", {
      desc: "Select jemalloc as memory allocator when building Redis",
      accept_value: { boolean: false }
    }

    def install
      args = %W[
        PREFIX=#{prefix}
        CC=#{ENV['CC']}
      ]
      args << "MALLOC=jemalloc" if with_jemalloc?
      run 'make', 'install', *args
      %w[run db/redis log].each { |p| FileUtils.mkdir_p "#{persist}/#{p}" }
      replace 'redis.conf', '/var/run/redis.pid', "#{persist}/run/redis.pid"
      replace 'redis.conf', 'dir ./', "dir #{persist}/db/redis"
      replace 'redis.conf', '# bind 127.0.0.1', 'bind 127.0.0.1'
      replace 'redis.conf', 'daemonize no', 'daemonize yes'
      FileUtils.mkdir etc
      FileUtils.cp 'redis.conf', etc
      FileUtils.cp 'sentinel.conf', "#{etc}/redis-sentinel.conf"
    end

    def start options = {}
      config_file = [config_file, options[:config_file], "#{etc}/redis.conf"].find { |x| x }
      run "#{bin}/redis-server #{config_file}"
    end

    def status
      run "#{bin}/redis-cli info", :skip_error
      $?.success? ? :on : :off
    end

    def stop
      return 'already off' if status == :off
      run "#{bin}/redis-cli shutdown"
    end
  end
end
