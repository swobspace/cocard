# frozen_string_literal: true

# methods with val only works with non ajax stuff

module Select2Helper
  # Select2 ajax programatic helper
  # It allows you to select value from select2
  #
  # Params
  #   value - real value of selected item
  #   opts - options containing css selector
  #
  # Usage:
  #
  #   select2(2, from: '#user_ids')
  #
  # source: gitlab.com/gitlab-org/gitlab-ce/spec/support/select2_helper.rb

  def select2(value, options = {})
    raise "Must pass a hash containing 'from'" if !options.is_a?(Hash) || !options.key?(:from)

    selector = options[:from]
    if options[:multiple]
      # page.execute_script("$('#{selector}').select2('val', ['#{value}']);")
      page.execute_script("$('#{selector}').select2('val', [#{value}]);")
    else
      page.execute_script("$('#{selector}').select2('val', '#{value}');")
    end
  end
end
