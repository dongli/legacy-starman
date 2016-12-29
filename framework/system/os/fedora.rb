module STARMAN
  class Fedora < Linux
    type :fedora
    version do
      `cat /etc/redhat-release 2>/dev/null`.match(/\d+(\.\d+)?(\.\d+)?/)[0] rescue nil
    end
  end
end
