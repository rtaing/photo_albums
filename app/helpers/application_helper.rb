module ApplicationHelper
  
  def alert_div(notice)
    notice ? "<div class='alert alert-warning'><p id='notice'>#{notice}</p></div>".html_safe : ''
  end
  
end
