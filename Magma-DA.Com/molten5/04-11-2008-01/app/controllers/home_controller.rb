class HomeController < ProtectedController
  def index
    @cases = current_contact.recently_updated_cases
    @popular_solutions = Sfsolution.find_popular_in_range(current_contact).map(&:first)
    @articles = SfmoltenPost.find_articles(:limit => AppConstants::ARTICLE_LIMIT)
    @new_solutions = Sfsolution.find_new(current_contact)
    @recently_viewed_solutions = current_contact.recent_sfsolutions
  end
  
  # This is a test action for demoing the marketing message
  def marketing
    @marketing = SfmoltenPost.check_marketing_message_for_contact(current_contact)
    index
  end
  
  # Hides the marketing message
  def hide_message
    # todo - mark the message as read
    render :update do |page|
      page.visual_effect :fade, "marketing"
    end
  end
  
  def custom
    @solution = current_contact.custom_home_page
  end
end
