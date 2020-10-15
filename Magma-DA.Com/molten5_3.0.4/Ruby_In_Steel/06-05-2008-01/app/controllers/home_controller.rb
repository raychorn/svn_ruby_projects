class HomeController < ProtectedController
  def index
    unless read_fragment(:controller => 'home', :action => 'index', :part => 'cases', :contact_id => current_contact.id )
      @cases = current_contact.recently_updated_cases
    end
    unless read_fragment(:action => 'index', :part => 'popular_solutions')
#      @popular_solutions = Sfsolution.find_popular
      @popular_solutions = Sfsolution.find_popular_in_range(current_contact).map(&:first)
    end
    @articles = SfmoltenPost.find_articles(:limit => AppConstants::ARTICLE_LIMIT)
    unless read_fragment(:action => 'index', :part => 'new_solutions')
      @new_solutions = Sfsolution.find_new(current_contact)
    end
    # @attachments = current_contact.attachments
    @recently_viewed_solutions = current_contact.recent_sfsolutions
  end
  
  def custom
    @solution = current_contact.custom_home_page
  end
end
