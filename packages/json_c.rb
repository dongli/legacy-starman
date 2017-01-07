module STARMAN
  class Json_c < Package
    url 'https://github.com/json-c/json-c/archive/json-c-0.12.1-20160607.tar.gz'
    sha256 '989e09b99ded277a0a651cd18b81fcb76885fea08769d7a21b6da39fb8a34816'
    version '0.12.1'

    def install
      args = %W[
        --prefix=#{prefix}
        --disable-dependency-tracking
        --disable-silent-rules
      ]
      run './configure', *args
      run 'make', 'install'
    end
  end
end
