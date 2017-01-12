module STARMAN
  class Tar < Package
    url 'https://ftpmirror.gnu.org/tar/tar-1.29.tar.gz'
    sha256 'cae466e6e58c7292355e7080248f244db3a4cf755f33f4fa25ca7f9a7ed09af0'
    version '1.29'

    label :compiler_agnostic
    label :system_first, command: 'tar', version: Proc.new { |cmd|
      `#{cmd} --version`.match(/\d+\.\d+(\.\d+)?/)[0]
    }, version_condition: '>= 1.23'

    # CVE-2016-6321
    # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=842339
    # https://sintonen.fi/advisories/tar-extract-pathname-bypass.txt
    patch do
      url 'https://sources.debian.net/data/main/t/tar/1.29b-1.1/debian/patches/When-extracting-skip-.-members.patch'
      sha256 '6b1371b9abd391e1654f7d730aae9c4dee703a867276b1e8a9ef97a2a906b7cf'
    end

    depends_on :xz

    def install
      if CompilerStore.compiler(:c).vendor == :intel
        CLI.report_error "#{CLI.blue 'tar'} can not be built by Intel C compiler!"
      end

      # Work around unremovable, nested dirs bug that affects lots of
      # GNU projects. See:
      # https://github.com/Homebrew/homebrew/issues/45273
      # https://github.com/Homebrew/homebrew/issues/44993
      # This is thought to be an el_capitan bug:
      # https://lists.gnu.org/archive/html/bug-tar/2015-10/msg00017.html
      if OS.mac? and OS.version =~ '10.11'
        ENV['gl_cv_func_getcwd_abort_bug'] = 'no'
      end

      args = %W[
        --prefix=#{prefix}
        --with-xz=#{Xz.bin}/xz
      ]

      run './configure', *args
      run 'make', 'install'
    end
  end
end
