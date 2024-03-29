Wobapphelpers.setup do |config|
  #
  # exclude some controllers from breadcrumbs
  # the given string must match controller.controller_name
  #
  # example:
  # config.breadcrumb_controller_blacklist = ["user_sessions"]
  # default:
  # config.breadcrumb_controller_blacklist = []
  #
  # show action links only if has ability to execute the action
  # * :none : always present action links
  # * :cancan1 : for cancancan '~>1.7.0' or cancan '~>1.6.0'
  # * :cancan2 : for cancan '~>2.0.0', untested
  #
  # default:
  # config.cancan = :none
end
