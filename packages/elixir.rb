module STARMAN
  class Elixir < Package
    url 'https://github.com/elixir-lang/elixir/archive/v1.3.4.tar.gz'
    sha256 'f5ee5353d8dbe610b1dfd276d22f2038d57d9a7d3cea69dac10da2b098bd2033'
    version '1.3.4'
    filename 'elixir-1.3.4.tar.gz'

    label :compiler_agnostic

    depends_on :erlang

    def install
      run 'make'
      mkdir_p bin
      ['elixir', 'elixirc', 'iex', 'mix'].each { |command| cp "bin/#{command}", bin }
      cp_r 'lib', prefix
    end
  end
end
