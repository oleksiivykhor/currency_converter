# frozen_string_literal: true

class HomeController < ApplicationController
  get '/' do
    prepare_variables

    erb :index
  end

  post '/' do
    prepare_variables

    erb :index
  end

  get '/update_rates' do
    service = RatesService.new
    service.update_currencies
    service.update_rates
    prepare_variables

    redirect '/'
  end

  private

  def prepare_variables
    @currencies = Currency.all.map(&:code)
    @calculations = calculate_amounts
  end

  def calculate_amounts
    attributes = {
      from: { currency: params[:from_currency], amount: params[:from_amount] },
      to: { currency: params[:to_currency], amount: params[:to_amount] }
    }
    CurrencyCalculationService.new(attributes).calculate
  end
end
