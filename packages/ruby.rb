module STARMAN
  class Ruby < Package
    homepage 'https://www.ruby-lang.org/'
    url 'https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.1.tar.bz2'
    sha256 '4a7c5f52f205203ea0328ca8e1963a7a88cf1f7f0e246f857d595b209eac0a4d'
    version '2.3.1'

    def abi_version
      '2.3.0'
    end

    label :compiler_agnostic

    has_patch

    depends_on :pkgconfig if needs_build?
    depends_on :readline
    depends_on :gmp
    depends_on :libyaml
    depends_on :openssl

    def export_env
      System::Shell.prepend 'PATH', "#{persist}/bin", separator: ':', system: true
    end

    def install
      args = %W[
        --prefix=#{prefix}
        --enable-shared
        --disable-silent-rules
        --with-opt-dir=#{Readline.prefix}:#{Gmp.prefix}:#{Libyaml.prefix}:#{Openssl.prefix}
      ]
      args << '--with-out-ext=tk'
      args << '--disable-install-doc'

      run './configure', *args
      run 'make'
      run 'make', 'install'
    end

    def post_install
      FileUtils.write "#{lib}/ruby/#{abi_version}/rubygems/defaults/operating_system.rb", rubygems_config
    end

    def rubygems_config; <<-EOT.keep_indent
      module Gem
        class << self
          alias :old_default_dir :default_dir
          alias :old_default_path :default_path
          alias :old_default_bindir :default_bindir
          alias :old_ruby :ruby
        end

        def self.default_dir
          path = [
            "#{persist}",
            "lib",
            "ruby",
            "gems",
            "#{abi_version}"
          ]

          @default_dir ||= File.join(*path)
        end

        def self.private_dir
          path = if defined? RUBY_FRAMEWORK_VERSION then
                   [
                     File.dirname(RbConfig::CONFIG['sitedir']),
                     'Gems',
                     RbConfig::CONFIG['ruby_version']
                   ]
                 elsif RbConfig::CONFIG['rubylibprefix'] then
                   [
                    RbConfig::CONFIG['rubylibprefix'],
                    'gems',
                    RbConfig::CONFIG['ruby_version']
                   ]
                 else
                   [
                     RbConfig::CONFIG['libdir'],
                     ruby_engine,
                     'gems',
                     RbConfig::CONFIG['ruby_version']
                   ]
                 end

          @private_dir ||= File.join(*path)
        end

        def self.default_path
          if Gem.user_home && File.exist?(Gem.user_home)
            [user_dir, default_dir, private_dir]
          else
            [default_dir, private_dir]
          end
      end

        def self.default_bindir
          "#{persist}/bin"
        end

        def self.ruby
          "#{bin}/ruby"
        end
      end
      EOT
    end
  end
end

__END__
From 2b41316953cdc92ab4d82b987bd1bf6870b2e752 Mon Sep 17 00:00:00 2001
From: Misty De Meo <mistydemeo@gmail.com>
Date: Mon, 28 Dec 2015 16:46:19 -0400
Subject: [PATCH] Revert "mkconfig.rb: SDKROOT"

This reverts commit e98f7ea423b08222b6eceda945613040c7b08a09.
---
 tool/mkconfig.rb | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/tool/mkconfig.rb b/tool/mkconfig.rb
index fdba709..ef9a4b0 100755
--- a/tool/mkconfig.rb
+++ b/tool/mkconfig.rb
@@ -131,8 +131,6 @@ def config.write(arg)
       if universal
         val.sub!(/universal/, %q[#{arch && universal[/(?:\A|\s)#{Regexp.quote(arch)}=(\S+)/, 1] || '\&'}])
       end
-    when /^includedir$/
-      val = '"$(SDKROOT)"'+val if /darwin/ =~ arch
     end
     v = "  CONFIG[\"#{name}\"] #{eq} #{val}\n"
     if fast[name]
@@ -245,9 +243,6 @@ module RbConfig

 print(*v_fast)
 print(*v_others)
-print <<EOS if /darwin/ =~ arch
-  CONFIG["SDKROOT"] = ENV["SDKROOT"] || "" # don't run xcrun everytime, usually useless.
-EOS
 print <<EOS
   CONFIG["archdir"] = "$(rubyarchdir)"
   CONFIG["topdir"] = File.dirname(__FILE__)
--
2.6.4
