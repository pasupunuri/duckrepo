class HomeController < ApplicationController
  def search
    @result = params[:query].blank? ? [] : DuckDuck.search(params) 
    render :search
  end
end
