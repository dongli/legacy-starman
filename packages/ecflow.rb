module STARMAN
  class Ecflow < Package
    homepage 'https://software.ecmwf.int/wiki/display/ECFLOW/Home'
    url 'https://software.ecmwf.int/wiki/download/attachments/8650755/ecFlow-4.5.0-Source.tar.gz?api=v2'
    sha256 '93dcf69e67165a626b7268432b9da9d3f55284a54145dc94caf7bc509c25ec87'
    version '4.5.0'

    option 'with-python3', {
      desc: 'Build Python 3 API.',
      accept_value: { boolean: false }
    }
    option 'with-qt5', {
      desc: 'Build GUI with Qt5',
      accept_value: { boolean: false }
    }

    depends_on :cmake if needs_build?
    depends_on :boost, 'with-python3' => with_python3?
    depends_on :python3 if with_python3?
    depends_on :qt5 if with_qt5?

    def export_env
      System::Shell.append 'PYTHONPATH', "#{lib}/"
    end

    def install
      args = std_cmake_args
      args << "-DBOOST_ROOT=#{Boost.prefix}"
      args << "-DBoost_NO_SYSTEM_PATHS=ON"
      args << "-DENABLE_STATIC_BOOST_LIBS=OFF"
      args << "-DENABLE_UI=OFF" if not with_qt5?
      args << "-DENABLE_GUI=ON"
      if with_python3?
        args << "-DPYTHON_EXECUTABLE=#{Python3.bin}/python3"
      else
        args << '-DENABLE_PYTHON=OFF'
        inreplace 'CMakeLists.txt', 'COMPONENTS python', 'COMPONENTS'
      end
      mkdir 'build' do
        run 'cmake', '..', *args
        run 'make'
        run 'make', 'check' if not skip_test?
        run 'make', 'install'
      end
    end
  end
end
