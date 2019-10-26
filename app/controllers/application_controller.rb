# frozen_string_literal: true

class ApplicationController < Sinatra::Base
  configure do
    set :root, Pathname.new(File.expand_path('../..', __dir__))
    set :views, root.join('app/views')
  end
end
