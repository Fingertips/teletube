#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

def basename
  @base ||= File.expand_path('../build/Teletube.app', __dir__)
end

def resources_source_path
  @resources_source_path ||= File.expand_path('../resources', __dir__)
end

def contents_path
  @contents_path ||= File.join(basename, 'Contents')
end

def frameworks_path
  @frameworks_path ||= File.join(contents_path, 'Frameworks')
end

def resources_path
  @resources_path ||= File.join(contents_path, 'Resources')
end

def mac_os_path
  @mac_os_path ||= File.join(contents_path, 'MacOS')
end

def dylibs(file, prefix = '/usr/local/opt')
  dylibs = []
  `otool -L #{file}`.split("\n\t").each do |line|
    dylibs << line.split(' ', 2).first if line.start_with?(prefix)
  end
  dylibs
end

def run(command)
  puts command
  `#{command}`
end

FileUtils.mkdir_p(mac_os_path)
FileUtils.mkdir_p(frameworks_path)
FileUtils.mkdir_p(resources_path)

FileUtils.cp(File.join(resources_source_path, 'Info.plist'), contents_path)
FileUtils.cp(File.join(resources_source_path, 'AppIcon.icns'), resources_path)

FileUtils.cp('teletube', mac_os_path)
exec_path = File.join(mac_os_path, 'teletube')

teletube_dylibs = dylibs(exec_path)
teletube_dylibs.each do |local_dylib_filename|
  app_dylib_filename = File.join(frameworks_path, File.basename(local_dylib_filename))
  FileUtils.cp_r(local_dylib_filename, app_dylib_filename) rescue Errno::EACCES
  app_dylib_name = File.basename(app_dylib_filename)
  run %[install_name_tool -change #{local_dylib_filename} @executable_path/../Frameworks/#{app_dylib_name} #{exec_path}]

  dylibs(app_dylib_filename, '/usr/local/Cellar').each do |cellar_dylib_filename|
    app_dylib_name = File.basename(cellar_dylib_filename)
    run %[install_name_tool -change #{cellar_dylib_filename} ./#{app_dylib_name} #{app_dylib_filename}]
  end
end

run %[rm -f build/Teletube.zip]
run %[cd build && zip -r Teletube.zip Teletube.app]