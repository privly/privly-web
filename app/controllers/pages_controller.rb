class PagesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:account]
  
  def faq
  end

  def join
  end

  def roadmap
  end

  def people
  end

  def license
  end

  def privacy
  end

  def terms
  end

  def help
  end

  def status
  end

  def irc
  end

  def bug
  end

  def donate
  end

  def download
  end

  def about
  end

  def email
  end
  
  def account
  end

end
