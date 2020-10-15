class HomeController < ProtectedController
  def index
    @marketing = SfmoltenPost.check_marketing_message_for_contact(current_contact)
    @cases = current_contact.recently_updated_cases
    @popular_solutions = Sfsolution.find_popular_in_range(current_contact).map(&:first)
    @articles = SfmoltenPost.find_articles(:limit => AppConstants::ARTICLE_LIMIT)
    @new_solutions = Sfsolution.find_new(current_contact)
    @recently_viewed_solutions = current_contact.recent_sfsolutions
  end
  
  def custom
    @solution = current_contact.custom_home_page
  end
end
