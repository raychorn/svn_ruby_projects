ActionController::Routing::Routes.draw do |map|
	# The priority is based upon order of creation: first created -> highest priority.

	# Sample of regular route:
	# map.connect 'products/:id', :controller => 'catalog', :action => 'view'
	# Keep in mind you can assign values other than :controller and :action

	# Sample of named route:
	# map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
	# This route can be invoked with purchase_url(:id => product.id)

	# You can have the root of your site routed by hooking up ''
	# -- just remember to delete public/index.html.
	# map.connect '', :controller => "welcome"

	# Allow downloading Web Service WSDL as a file with an extension
	# instead of a file named 'wsdl'
	map.connect ':controller/service.wsdl', :action => 'wsdl'

	map.resources :computers
	map.resources :computer_groups
	map.resources :graphs
	map.resources :vulns
	map.resources :platform_benchmarks
	map.resources :benchmark_versions
	map.resources :benchmark_check_groups
	map.resources :benchmark_checks
	map.resources :apps
	map.resources :users, :sessions

	# trend data
	map.connect 'trend_chart/delta_types_by_metric/:metric_id', :controller => 'trend_chart', :action => 'delta_types_by_metric'
	map.connect 'trend_chart/:action/:computer_group_id/:metric_id', :controller => 'trend_chart'
	# Install the default route as the lowest priority.
	map.connect ':controller/:action/:id.:format'
	map.connect ':controller/:action/:id'
end
