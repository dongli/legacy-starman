module STARMAN
  class Mac < OS
    type :mac
    version `sw_vers`.match(/ProductVersion:\s*(\d+\.\d+(\.\d+)?)/)[1]
  end
end
