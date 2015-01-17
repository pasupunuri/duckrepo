module ApplicationHelper
  def previous_page
    params[:page].to_i - 1
  end
  
  def next_page
    params[:page].to_i + 1
  end
  
  def current_type
    params[:type] == 'topic' ? 'topic' : 'web'
  end
end
