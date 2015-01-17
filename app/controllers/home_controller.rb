class HomeController < ApplicationController
  def search
    @result = params[:query] ? DuckDuck.get(params) : []
    render :search
  end
end
