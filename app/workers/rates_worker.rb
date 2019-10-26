# frozen_string_literal: true

require File.expand_path('../../config/environment', __dir__)
require 'sidekiq-scheduler'

class RatesWorker
  include Sidekiq::Worker

  def perform
    service = RatesService.new
    service.update_currencies
    service.update_rates
  end
end
