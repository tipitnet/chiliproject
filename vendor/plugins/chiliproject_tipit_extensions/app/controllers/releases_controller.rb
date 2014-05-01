class ReleasesController < ApplicationController

  def show
    version = Version.find_by_name(params[:id])
    redirect_to "/versions/show/#{version.id}"
  end

end