module STARMAN
  class Curl < Package
    homepage 'https://curl.haxx.se/'
    url 'https://curl.haxx.se/download/curl-7.48.0.tar.bz2'
    sha256 '864e7819210b586d42c674a1fdd577ce75a78b3dda64c63565abe5aefd72c753'
    version '7.48.0'

    depends_on :openssl
  end
end
