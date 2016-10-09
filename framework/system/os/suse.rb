module STARMAN
  class SUSE < Linux
    type :suse
    version do
      tmp = `cat /etc/*-release 2>&1`
      "#{tmp.match(/VERSION\s*=\s*(\d+)/)[1]}.#{tmp.match(/PATCHLEVEL\s*=\s*(\d+)/)[1]}" rescue nil
    end
  end
end
