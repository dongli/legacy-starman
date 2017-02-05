module STARMAN
  class Icu4c < Package
    homepage 'http://site.icu-project.org/'
    url 'https://ssl.icu-project.org/files/icu4c/57.1/icu4c-57_1-src.tgz'
    sha256 'ff8c67cb65949b1e7808f2359f2b80f722697048e90e7cfc382ec1fe229e9581'
    version '57.1'

    def install
      # Add --enable-rpath to allow icu4c library paths to be embeded into other files.
      args = %W[
        --prefix=#{prefix}
        --disable-samples
        --disable-tests
        --enable-static
        --with-library-bits=64
      ]
      work_in 'source' do
        run './configure', *args
        run 'make'
        run 'make', 'test' unless skip_test?
        run 'make', 'install'
      end
    end
  end
end
