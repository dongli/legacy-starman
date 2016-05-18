require 'fileutils'

module FileUtils
  class << self
    alias_method :old_mkdir_p, :mkdir_p

    def mkdir_p list, options = {}
      begin
        old_mkdir_p list, options
      rescue Errno::EACCES => e
        STARMAN::CLI.report_error "Failed to create directory #{STARMAN::CLI.red list}! Create it manually by using sudo, then back."
      end
    end
  end
end
