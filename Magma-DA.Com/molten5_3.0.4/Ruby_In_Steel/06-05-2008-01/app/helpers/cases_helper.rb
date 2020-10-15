module CasesHelper
  def link_to_toggle_additional_information(name = "Additional Information")
    link_to_function name, "Element.toggle('case_additional_information');
                            Element.toggle('show_info');
                            Element.toggle('hide_info');",
                            :id => 'toggle_additional_info'
  end
  
  def search?
    controller.action_name == 'search'
  end
  
  def tag_for_cases(status)
    "#{status}_cases"
  end
  
  def tag_for_hide_cases(status)
    "hide_#{status}"
  end
  
  def tag_for_show_cases(status)
    "show_#{status}"
  end
  
  def rowspan_size
    (params[:all] ? current_contact.settings.case_columns_setting.all_selected_case_columns.size+2 : current_contact.settings.case_columns_setting.your_selected_case_columns.size+2)
  end
  
  # Creates a link to sort the results by the specified column.
  # No links are created when searching.
  def link_to_sort(name,column)
    return name if search?
    if column == @sort
      order = ('ASC' == @order ? 'DESC' : 'ASC')
    else
      order = 'ASC'
    end
    link = link_to(name, params.merge({:sort => column, :order => order}))
    image = build_sort_image(column,order)
    "#{link} #{image}"
  end
  
  # Creates a button and link to subscribe or unsubscribe to the
  # +current_user+'s account cases.
  def link_to_subscribe_to_cases
   html = if current_contact.share_cases?(current_contact.company)
            link_to image_tag('buttons/share_cases.gif'),
                    :controller => 'case_watchers',
                    :action => 'account',
                    :id => current_contact.company   
     elsif SfcaseWatcher.find_for_contact_and_account(current_contact)
            link_to_remote image_tag('buttons/unsubscribe.gif'), 
                     {:url => {:controller => 'case_watchers',
                              :action => 'unsubscribe',
                              :account => current_contact.company.id,
                              :from => controller.action_name},
                      :loading => "Element.toggle('sub_indicator');Element.hide('subscribe_link')"
                     },
                     {:id => 'subscribe_link'}
   else
      link_to_remote image_tag('buttons/subscribe.gif'), 
                     {:url => {:controller => 'case_watchers',
                              :action => 'subscribe',
                              :account => current_contact.company.id,
                              :from => controller.action_name},
                      :loading => "Element.toggle('sub_indicator');Element.hide('subscribe_link')"
                     },
                     {:id => 'subscribe_link'}
    end
    html += sub_indicator
    html
  rescue  ActiveRecord::StatementInvalid
    "connection error"
  end
  
  def link_to_subscribe_to_case(support_case = @case, options = {})
    html = if current_contact.share_cases?(current_contact.company)
              link_to image_tag('buttons/share_this_case.gif'),
                      :controller => 'case_watchers',
                      :action => 'case',
                      :id => support_case
          elsif !options[:subscribe] and SfcaseWatcher.find_for_contact_and_support_case(current_contact, support_case)
              link_to_remote image_tag('buttons/unsubscribe.gif'), 
                             {:url => {:controller => 'case_watchers',
                                      :action => 'unsubscribe',
                                      :support_case => support_case.id, 
                                      :from => controller.action_name},
                              :loading => "Element.toggle('sub_indicator');Element.hide('subscribe_link')"
                             },
                             {:id => 'subscribe_link'}
          else
            link_to_remote image_tag('buttons/subscribe.gif'), 
                           {:url => {:controller => 'case_watchers',
                                    :action => 'subscribe',
                                    :support_case => support_case.id,
                                    :from => controller.action_name},
                            :loading => "Element.toggle('sub_indicator');Element.hide('subscribe_link')"
                           },
                           {:id => 'subscribe_link'}
         end
    html += sub_indicator
    html
  rescue
  end
  
  def set_subscribe_link(options = {})
    if params[:from] == 'show'
      link_to_subscribe_to_case(Sfcase.find(params[:support_case]), options)
    else
      link_to_subscribe_to_cases
    end
  end
  
  ### Form Helpers ###
  # These are used to only make the field editable if:
  # - the associated +@case+ is new
  # - the case is an existing case and the attribute is listed in Sfcase::EDITABLE_ATTRIBUTES
  
  
  # def case_text_field(object_name, method, options = {})
  #     sfcase = instance_variable_get(object_name)
  #     if sfcase.new_record? or Sfcase::EDITABLE_ATTRIBUTES.include?(method.to_s)
  #       text_field(object_name, method, options = {})
  #     else
  #       sfcase.send(method)
  #     end
  #   end
  
  def case_text_field(object_name, method, options = {})
    sfcase = instance_variable_get('@'+object_name)
    do_case_form_field(sfcase, method) { text_field(object_name, method, options) }
  end
  
  def case_select_tag(name, option_tags = nil, options = {})
    sfcase = @case
    name =~ /\[\w+\]/ 
    method = $&.gsub(/\[|\]/,'')
    do_case_form_field(sfcase, method) { select_tag(name, option_tags, options) }
  end
  
  def case_text_area(object_name, method, options = {})
    sfcase = instance_variable_get('@'+object_name)
    do_case_form_field(sfcase, method) { text_area(object_name, method, options) }
  end
  
  def case_date_select(object_name, method, options = {})
    sfcase = instance_variable_get('@'+object_name)
    do_case_form_field(sfcase, method) { date_select(object_name, method, options) }
  end
  
  def do_case_form_field(sfcase, method)
    if sfcase.new_record? or Sfcase::EDITABLE_ATTRIBUTES.include?(method.to_s)
      yield
    else
      html = "<span style='font-weight:normal'>"
      html << (sfcase.send(method).to_s || 'N/A')
      html << '</span>'
    end
  end
  
  private
  
  def sub_indicator
    html =<<-END_STRING
      <div style="display:none" id='sub_indicator'>
				#{image_tag('indicator_arrows_circle.gif', 
					:style => "margin-left:42px;margin-right:42px;padding-top:5px")}
			</div>
    END_STRING
  end
  
  # Creates a sort arrow indictator. If +@sort+ isn't set, we default to display next to 
  # 'last updated'
  def build_sort_image(column,order)
    if column == @sort or (@sort.nil? and column == 'sfcase.last_modified_date')
      image_tag("icons/#{order}.gif", :width => 7, :height => 5, :alt => order)
    end
  end
end
