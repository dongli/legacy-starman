module STARMAN
  class CentOS < Linux
    type :centos
    version do
      `cat /etc/redhat-release`.match(/\d+\.\d+\.\d+/)[0]
    end
  end
end
