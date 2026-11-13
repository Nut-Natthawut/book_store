class AdminController < ApplicationController
  before_action :require_admin

  def show
    @books = Book.includes(:category).order(:title)
  end
end
