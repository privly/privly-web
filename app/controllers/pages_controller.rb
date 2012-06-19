class PagesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:account]

  def join
    @sidebar = {:contribute => true}
  end

  def roadmap
    @sidebar = {:about => true}
  end

  def license
    @sidebar = {:contribute => true}
  end

  def privacy
    @sidebar = {:contribute => true}
  end

  def donate
    @sidebar = {:contribute => true}
  end

  def download
    @sidebar = {:contribute => true}
  end

  def about
    @sidebar = {:about => true, :in_the_news => true}
  end
  
  def kickstarter
    @sidebar = {:news => true, :about => true, :contribute => true}
  end
  
  def account
  end

end
