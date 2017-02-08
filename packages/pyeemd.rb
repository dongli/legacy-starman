module STARMAN
  class Pyeemd < Package
    url 'https://bitbucket.org/luukko/pyeemd/get/v1.4.tar.bz2'
    sha256 '40c10400de049ba6c5515364b954c9daa4970a44c80be472c3a69873ac67ad71'
    version '1.4'
    filename 'pyeemd-1.4.tar.bz2'

    depends_on :python3
    depends_on :libeemd

    def export_env
      System::Shell.append 'PYTHONPATH', "#{prefix}/lib/python#{Python3.xy}/site-packages", separator: ':'
    end

    def install
      ENV['LIBRARY_PATH'] = Libeemd.lib
      export_env
      mkdir_p "#{prefix}/lib/python#{Python3.xy}/site-packages"
      run 'python3', 'setup.py', 'install', "--prefix=#{prefix}"
    end
  end
end
