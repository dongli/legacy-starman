module STARMAN
  class SUSE < Linux
    type :suse
    version do
      tmp = `cat /etc/*-release`
      "#{tmp.match(/VERSION\s*=\s*(\d+)/)[1]}.#{tmp.match(/PATCHLEVEL\s*=\s*(\d+)/)[1]}"
    end
  end
end
