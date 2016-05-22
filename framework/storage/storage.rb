module STARMAN
  class Storage
    class << self
      def tar_name package
        "#{package.tag}.tgz"
      end

      def init adapter
        @@adapter = eval "#{adapter.to_s.capitalize}Adapter"
        @@adapter.init
      end

      [:uploaded?, :upload!, :delete!, :download].each do |action|
        class_eval <<-EOT
          def #{action} package
            @@adapter.#{action} package
          end
        EOT
      end
    end
  end
end
