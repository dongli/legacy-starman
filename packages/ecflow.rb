module STARMAN
  class Ecflow < Package
    homepage 'https://software.ecmwf.int/wiki/display/ECFLOW/Home'
    url 'https://software.ecmwf.int/wiki/download/attachments/8650755/ecFlow-4.1.0-Source.tar.gz'
    sha256 '9cc4074565deddc6dc5e7ca5953926f5d59ebd1a2b85de29d7951d755212f9fb'
    version '4.1.0'

    option 'with-qt5', {
      desc: 'Build GUI with Qt5',
      accept_value: { boolean: false }
    }

    depends_on :python3
    depends_on :boost, 'with-python3' => true
    depends_on :cmake if needs_build?

    # def export_env
    #   System::Shell.append 'PYTHONPATH', "#{lib}/"
    # end

    def install
      args = std_cmake_args
      args << "-DBOOST_ROOT=#{Boost.prefix}"
      args << "-DBOOST_LIBRARYDIR=#{Boost.lib}"
      args << "-DBoost_NO_SYSTEM_PATHS=ON"
      args << "-DENABLE_UI=OFF" if not with_qt5?
      args << "-DENABLE_GUI=ON"
      args << "-DPYTHON_EXECUTABLE=#{Python3.bin}/python3"
      mkdir 'build' do
        run 'cmake', '..', *args
        run 'make'
        run 'make', 'check' if not skip_test?
        run 'make', 'install'
      end
    end
  end
end
