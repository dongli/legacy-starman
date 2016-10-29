module STARMAN
  class Zhparser < Package
    url 'https://codeload.github.com/amutu/zhparser/zip/de966445dab64b91378527219988f36107b7b2e8'
    sha256 '7fbde6f5929cbdc1af7e374a3e33da3a4224680274e0ebf176c3e7dcfa5a1bfa'
    version 'de9664'
    filename 'zhparser-de9664.zip'

    label :parasite, into: :postgresql

    depends_on :scws
    depends_on :postgresql

    def install
      ENV['SCWS_HOME'] = Scws.prefix
      run 'make'
      run 'make install'
    end
  end
end
