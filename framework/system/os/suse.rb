module STARMAN
  class Ubuntu < Linux
    type :suse
    version do
      `cat /etc/os-release`.match(/SUSE (\d+\.\d+)/)[1]
    end
  end
end
