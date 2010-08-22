ActionController::Routing::Routes.draw do |map|
  map.namespace('sme') do |sme|
    sme.root :controller => :metrics
  end
end
