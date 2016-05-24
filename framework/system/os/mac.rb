module STARMAN
  class Mac < OS
    type :mac
    version `sw_vers`.match(/ProductVersion:\s*(\d+\.\d+(\.\d+)?)/)[1]
    soname :dylib
    ld_library_path 'DYLD_LIBRARY_PATH'
  end
end
