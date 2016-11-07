module STARMAN
  class Elasticsearch < Package
    homepage 'https://www.elastic.co'
    url 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.0.0.tar.gz'
    sha256 'a866534f0fa7428e980c985d712024feef1dee04709add6e360fc7b73bb1e7ae'
    version '5.0.0'

    def install
      rm_f 'bin/*.bat'
      rm_f 'bin/*.exe'
      mkdir_p persist
      mkdir_p "#{var}/log/elasticsearch"
      cp_r ['bin', 'config', 'lib', 'modules'], prefix
      inreplace "#{prefix}/config/elasticsearch.yml", {
        /#\s*cluster\.name\: .*/ => "cluster.name: elasticsearch_#{ENV['USER']}",
        %r{#\s*path\.data: /path/to.+$} => "path.data: #{persist}/",
        %r{#\s*path\.logs: /path/to.+$} => "path.logs: #{var}/log/elasticsearch/"
      }
      inreplace "#{bin}/elasticsearch.in.sh", {
        %r{#\!/bin/bash\n} => "#!/bin/bash\n\nES_HOME=#{prefix}"
      }
      inreplace "#{bin}/elasticsearch-plugin", {
        /SCRIPT="\$0"/ => %Q(SCRIPT="$0"\nES_CLASSPATH=#{lib}),
        %r{\$ES_HOME/lib/} => "$ES_CLASSPATH/"
      }
    end

    def get_pid
      if File.exist? "#{var}/pid"
        File.read "#{var}/pid"
      end
    end

    def start
      if not get_pid
        run "#{bin}/elasticsearch --silent --daemonize --pidfile #{var}/pid", :screen_output, :skip_error
      else
        CLI.report_notice "#{CLI.blue 'Elasticsearch'} is already #{CLI.green 'on'}."
      end
    end

    def stop
      if pid = get_pid
        run "kill -s SIGTERM #{pid}", :screen_output, :skip_error
      else
        CLI.report_notice "#{CLI.blue 'Elasticsearch'} is already #{CLI.red 'off'}."
      end
    end

    def status
      if pid = get_pid
        CLI.report_notice "#{CLI.blue 'Elasticsearch'} is #{CLI.green 'on'} (pid: #{pid})."
        run "curl http://localhost:9200/_cat/health?v", :screen_output, :skip_error
        run "curl http://localhost:9200/_cat/nodes?v", :screen_output, :skip_error
        run "curl http://localhost:9200/_cat/indices?v", :screen_output, :skip_error
      else
        CLI.report_notice "#{CLI.blue 'Elasticsearch'} is #{CLI.red 'off'}."
      end
    end
  end
end
