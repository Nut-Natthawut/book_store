class AdminController < ApplicationController
  before_action :require_admin

  def index
    @books = Book.includes(:category).order(:title)
  end
end
