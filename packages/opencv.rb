module STARMAN
  class Opencv < Package
    homepage 'http://opencv.org'
    url 'https://github.com/opencv/opencv/archive/3.2.0.tar.gz'
    sha256 'b9d62dfffb8130d59d587627703d5f3e6252dce4a94c1955784998da7a39dd35'
    version '3.2.0'
    filename 'opencv-3.2.0.tar.gz'

    option 'with-python2', {
      desc: 'Build with Python 2 support.',
      accept_value: { boolean: true }
    }
    option 'with-python3', {
      desc: 'Build with Python 3 support.',
      accept_value: { boolean: true }
    }
    option 'with-qt5', {
      desc: 'Build the Qt5 backend to HighGUI',
      accept_value: { boolean: true }
    }
    option 'with-cuda', {
      desc: 'Build with Cuda support.',
      accept_value: { boolean: false }
    }

    depends_on :cmake if needs_build?
    depends_on :python2 if with_python2?
    depends_on :python3 if with_python3?
    depends_on :qt5
    depends_on :eigen
    depends_on :jasper
    depends_on :libjpeg
    depends_on :libpng
    depends_on :libtiff
    depends_on :webp
    depends_on :tbb
    depends_on :zlib
    depends_on :glog

    resource :contrib do
      url 'https://github.com/opencv/opencv_contrib/archive/3.2.0.tar.gz'
      sha256 '1e2bb6c9a41c602904cc7df3f8fb8f98363a88ea564f2a087240483426bf8cbe'
      filename 'opencv-contrib-3.2.0.tar.gz'
    end

    if OS.mac?
      resource :icv do
        url 'https://raw.githubusercontent.com/opencv/opencv_3rdparty/81a676001ca8075ada498583e4166079e5744668/ippicv/ippicv_macosx_20151201.tgz'
        sha256 '8a067e3e026195ea3ee5cda836f25231abb95b82b7aa25f0d585dc27b06c3630'
      end
    elsif OS.linux?
      resource :icv do
        url 'https://raw.githubusercontent.com/opencv/opencv_3rdparty/81a676001ca8075ada498583e4166079e5744668/ippicv/ippicv_linux_20151201.tgz'
        sha256 '4333833e40afaa22c804169e44f9a63e357e21476b765a5683bcb3760107f0da'
      end
    end

    def install
      run 'pip2', 'install', '--upgrade', 'numpy' if with_python2?
      run 'pip3', 'install', '--upgrade', 'numpy' if with_python3?
      args = std_cmake_args + %W[
        -DBUILD_JASPER=OFF
        -DBUILD_JPEG=OFF
        -DJPEG_INCLUDE_DIR=#{Libjpeg.inc}
        -DJPEG_LIBRARY=#{Libjpeg.lib}/libjpeg.#{OS.soname}
        -DBUILD_TIFF=OFF
        -DBUILD_OPENEXR=OFF
        -DBUILD_PNG=OFF
        -DZLIB_ROOT=#{Zlib.prefix}
        -DBUILD_ZLIB=OFF
        -DBUILD_TBB=OFF
      ]
      args << "-DCMAKE_PREFIX_PATH=#{Qt5.prefix}" << '-DWITH_QT=ON' if with_qt5?
      args << '-DBUILD_TESTS=OFF' << '-DBUILD_PERF_TESTS=OFF' if not skip_test?
      args << '-DWITH_EIGEN=ON'
      args << '-DWITH_JASPER=ON'
      args << '-DWITH_TBB=ON'
      if with_python2?
        args << '-DBUILD_opencv_python2=ON'
        args << "-DPYTHON2_EXECUTABLE=#{Python2.bin}/python2"
        args << "-DPYTHON2_LIBRARY=#{Python2.lib}/libpython2.7.#{OS.soname}"
        args << "-DPYTHON2_INCLUDE_DIR=#{Python2.inc}/python2.7"
      else
        args << '-DBUILD_opencv_python2=OFF'
        args << "-DPYTHON2_EXECUTABLE=''"
      end
      if with_python3?
        args << '-DBUILD_opencv_python3=ON'
        args << "-DPYTHON3_EXECUTABLE=#{Python3.bin}/python3"
        args << "-DPYTHON3_LIBRARY=#{Python3.lib}/libpython#{Python3.xy}m.#{OS.soname}"
        args << "-DPYTHON3_INCLUDE_DIR=#{Python3.inc}/python#{Python3.xy}m"
      else
        args << '-DBUILD_opencv_python3=OFF'
        args << "-DPYTHON3_EXECUTABLE=''"
      end

      install_resource :contrib, 'opencv_contrib', strip_leading_dirs: 1
      args << "-DOPENCV_EXTRA_MODULES_PATH=#{pwd}/opencv_contrib/modules"

      ['FFMPEG', 'V4L', 'DSHOW', 'MSMF', 'XIMEA', 'XINE', 'INTELPERC', 'GPHOTO2',
       'UNICAP', 'AVFOUNDATION', 'GSTREAMER', 'GTK', 'OPENNI'].each do |lib|
        args << "-DWITH_#{lib}=OFF"
      end

      args << '-DWITH_CARBON=ON' if OS.mac? and CompilerStore.compiler(:cxx).vendor == :gcc

      inreplace '3rdparty/ippicv/downloader.cmake',
        "${OPENCV_ICV_PLATFORM}-${OPENCV_ICV_PACKAGE_HASH}",
        "${OPENCV_ICV_PLATFORM}"
      inreplace 'cmake/OpenCVFindLibsPerf.cmake',
        "$ENV{EIGEN_ROOT}/include", "#{Eigen.inc}/eigen3"
      inreplace 'opencv_contrib/modules/cnn_3dobj/FindGlog.cmake',
        '/usr/local/lib', Glog.lib
      inreplace 'opencv_contrib/modules/sfm/CMakeLists.txt', {
        'set(GLOG_LIBRARIES "glog")' => 'set(GLOG_LIBRARIES "")',
        '${GLOG_INCLUDE_DIRS}' => Glog.inc,
        '${GFLAGS_INCLUDE_DIRS}' => Gflags.inc,
        '${GLOG_LIBRARIES}' => "#{Glog.lib}/libglog.#{OS.soname}",
        '${GFLAGS_LIBRARIES}' => "#{Gflags.lib}/libgflags.#{OS.soname}"
      }

      platform = OS.mac? ? "macosx" : "linux"
      mkdir_p "3rdparty/ippicv/downloads/#{platform}"
      cp resource(:icv).path, "3rdparty/ippicv/downloads/#{platform}"

      mkdir 'build' do
        run 'cmake', '..', *args
        run 'make'
        run 'make', 'install'
      end
    end
  end
end
