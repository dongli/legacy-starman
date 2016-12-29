module STARMAN
  class Mac < OS
    type :mac
    version do
      `sw_vers`.match(/ProductVersion:\s*(\d+\.\d+(\.\d+)?)/)[1] rescue nil
    end
    soname :dylib
    ld_library_path 'DYLD_LIBRARY_PATH'

    hardware do
      res = `system_profiler SPHardwareDataType`
      res = {
        model_name: res.match(/Model Name: (.*)/)[1],
        model_id: res.match(/Model Identifier: (.*)/)[1],
        cpu_name: res.match(/Processor Name: (.*)/)[1],
        cpu_freq: res.match(/Processor Speed: (.*)/)[1],
        num_cpu: res.match(/Number of Processors: (.*)/)[1],
        num_core: res.match(/Total Number of Cores: (.*)/)[1],
        memory: res.match(/Memory: (.*)/)[1]
      }
    end

    command :check_user do |name|
      res = `id -u #{name} 2>&1`
      $?.success?
    end
    command :check_group do |name|
      res = `dscl . list /Groups | grep #{name} 2>&1`
      $?.success?
    end
    command :get_unique_id do
      existed_ids = `dscl . list /Users UniqueID`.gsub(/^[^\s]+\s+/, '').split("\n").map { |id| id.to_i }
      id = 500
      id += 1 until not existed_ids.include? id
      id
    end
    command :get_primary_group_id do
      existed_ids = `dscl . list /Users PrimaryGroupID`.gsub(/^[^\s]+\s+/, '').split("\n").map { |id| id.to_i }
      id = 500
      id += 1 until not existed_ids.include? id
      id
    end
    command :create_user do |name, *options|
      CLI.report_notice "Create user #{CLI.blue name}."
      CLI.report_error "User #{CLI.red name} exists!" if check_user name
      res = `sudo dscl . create /Users/#{name} 2>&1`
      CLI.report_error "Failed to create user #{CLI.red name}! See errors:\n#{res}" if not $?.success?
      res = `sudo dscl . create /Users/#{name} UserShell /bin/bash`
      CLI.report_error "Failed to set user shell for #{CLI.red name}! See errors:\n#{res}" if not $?.success?
      unique_id = get_unique_id
      res = `sudo dscl . create /Users/#{name} UniqueID #{unique_id} 2>&1`
      CLI.report_error "Failed to set user id for #{CLI.red name}! See errors:\n#{res}" if not $?.success?
      primary_group_id = get_primary_group_id
      res = `sudo dscl . create /Users/#{name} PrimaryGroupID #{primary_group_id} 2>&1`
      CLI.report_error "Failed to set group id for #{CLI.red name}! See errors:\n#{res}" if not $?.success?
      CLI.report_notice "Please enter a password for user #{CLI.blue name}:"
      system "sudo dscl . passwd /Users/#{name}"
      CLI.report_error "Failed to set password for #{CLI.red name}!" if not $?.success?
      if options.include? :with_group
        res = `sudo dscl . create /Groups/#{name}`
        CLI.report_error "Failed to create group #{CLI.red name}! See error:\n#{res}" if not $?.success?
        res = `sudo dscl . create /Groups/#{name} passwd "*"`
        CLI.report_error "Failed to passwd group #{CLI.red name}! See error:\n#{res}" if not $?.success?
        res = `sudo dscl . create /Groups/#{name} gid #{primary_group_id}`
        CLI.report_error "Failed to set group id for #{CLI.red name}! See error:\n#{res}" if not $?.success?
      end
      if options.include? :with_home
        res = `sudo dscl . create /Users/#{name} NFSHomeDirectory /Users/#{name}`
        CLI.report_error "Failed to create home for #{CLI.red name}!" if not $?.success?
        if not File.directory? "/Users/#{name}"
          res = `sudo mkdir /Users/#{name}`
          CLI.report_error "Failed to create home for #{CLI.red name}!" if not $?.success?
        end
        if options.include? :with_group
          change_owner "/Users/#{name}", name+':'+name
        else
          change_owner "/Users/#{name}", name
        end
      end
      if options.include? :hide_login
        res = `sudo defaults write /Library/Preferences/com.apple.loginwindow HiddenUsersList -array-add #{name}`
        CLI.report_error "Failed to hide #{CLI.red name} from login screen!" if not $?.success?
      end
    end
    command :change_owner do |path, owner|
      CLI.report_notice "Change owner of #{CLI.blue path} to #{CLI.blue owner}."
      res = `sudo chown -R #{owner} #{path} 2>&1`
      CLI.report_error "Failed to change owner of #{CLI.red path} to #{CLI.red owner}! See errors:\n#{res}" if not $?.success?
    end
  end
end
