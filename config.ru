# frozen_string_literal: true

require File.expand_path('config/environment', __dir__)

Dir.glob('./app/controllers/*.rb').each do |path|
  file_name = File.basename(path, '.rb')
  controller = file_name.classify.safe_constantize

  run controller if controller
end
