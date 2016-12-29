module STARMAN
  class AIX < OS
    type :aix
    version do
      `oslevel -s`.chomp rescue nil
    end
    soname :so
    ld_library_path 'LD_LIBRARY_PATH'
  end
end
