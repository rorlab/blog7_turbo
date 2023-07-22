class PagesController < ApplicationController
  def home
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('nav', partial: 'pages/home')
      end
    end    
  end

  def about
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: turbo_stream.update('nav', partial: 'pages/about')
      end
    end
  end
end
