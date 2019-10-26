# frozen_string_literal: true

ENV['RACK_ENV'] ||= 'development'
ENV['SINATRA_ENV'] ||= 'development'

require 'sinatra/base'
require 'bundler/setup'
require 'active_support/all'

Bundler.require(:default, ENV['SINATRA_ENV'])

path = './app/{controllers,services,models}/*.rb'
Dir.glob(path).each { |file| require file }
