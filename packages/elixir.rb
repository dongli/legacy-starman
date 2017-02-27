module STARMAN
  class Elixir < Package
    url 'https://github.com/elixir-lang/elixir/archive/v1.4.2.tar.gz'
    sha256 'cb4e2ec4d68b3c8b800179b7ae5779e2999aa3375f74bd188d7d6703497f553f'
    version '1.4.2'
    filename 'elixir-1.4.2.tar.gz'

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
