module STARMAN
  class Curl < Package
    homepage 'https://curl.haxx.se/'
    url 'https://curl.haxx.se/download/curl-7.50.1.tar.bz2'
    sha256 '3c12c5f54ccaa1d40abc65d672107dcc75d3e1fcb38c267484334280096e5156'
    version '7.50.1'
    language :c

    depends_on :openssl

    def install

    end
  end
end
