class AdminController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def show
    authorize Book, :update?
    @books = Book.includes(:category).order(:title)
  end
end
