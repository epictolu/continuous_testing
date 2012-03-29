require "filesystemwatcher"
require "" # Need to determine which action to take
require "" # Need to fill out properties file

watcher = FileSystemWatcher.new()
watcher.addDirectory(@directory_to_watch, @extensions_to_watch)

@ignored_directories.split(",").each do |ignored_directory|
	watcher.ignoreDirectory(ignored_directory.strip)
end

watcher.start {
	|status, file|
	if(status == FileSystemWatcher::CREATED) then
		when_a_file_is_created file
	elsif(status == FileSystemWatcher::MODIFIED) then
		when_a_file_is_modified file
	elsif(status == FileSystemWatcher::DELETED) then
		when_a_file_is_deleted file
	end
}

watcher.join()
