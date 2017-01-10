module STARMAN
  class Netcdf_python < Package
    url 'https://github.com/Unidata/netcdf4-python/archive/v1.2.7rel.tar.gz'
    sha256 '42255f15341ae1959f814443385af4be5ae012b42e2202f300a5e5095338f54e'
    version '1.2.7'
    filename 'netcdf-python-1.2.7.tar.gz'

    belongs_to :netcdf

    depends_on :python3

    def export_env
      System::Shell.append 'PYTHONPATH', "#{prefix}/lib/python3.5/site-packages", separator: ':'
    end

    def install
      run 'pip3', 'install', '--upgrade', 'numpy'
      export_env
      mkdir_p "#{prefix}/lib/python3.5/site-packages"
      run 'python3', 'setup.py', 'install', "--prefix=#{prefix}"
    end
  end
end
