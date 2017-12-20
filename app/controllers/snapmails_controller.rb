class SnapmailsController < ApplicationController

  def history
    @snapmails_history = SnapmailsHistory.all
  end
end