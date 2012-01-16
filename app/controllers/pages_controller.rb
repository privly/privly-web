class PagesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:account]
  
  def faq
    @sidebar = {:news => false, :help => true}
  end

  def join
    @sidebar = {:news => false, :contribute => true}
  end

  def roadmap
    @sidebar = {:news => false, :about => true}
  end

  def people
    @sidebar = {:news => false, :about => true}
  end

  def license
    @sidebar = {:news => false, :contribute => true}
  end

  def privacy
    @sidebar = {:news => false, :about => true}
  end

  def terms
    @sidebar = {:news => false, :about => true}
  end

  def help
    @sidebar = {:news => false, :help => true}
  end

  def irc
    @sidebar = {:news => false, :help => true}
  end

  def bug
    @sidebar = {:news => false, :contribute => true}
  end

  def donate
    @sidebar = {:news => false, :contribute => true}
  end

  def download
    @sidebar = {:news => false, :contribute => true}
  end

  def about
    @sidebar = {:news => false, :about => true}
  end

  def email
    @sidebar = {:news => false, :help => true}
  end
  
  def account
  end

end
