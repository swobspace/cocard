module ApplicationHelper
  include Pagy::Frontend
  include Wobapphelpers::Helpers::All

  def configuration_active_class
    if Cocard::CONFIGURATION_CONTROLLER.include?(controller.controller_name.to_s)
      "active"
    end
  end

  def tag_list_input(form)
    form.input :tag_list_input,
               input_html: {
                 value: form.object.tag_list.to_json,
                 class: "form-select",
                 data: { controller: "tagging",
                         "tagging-options-value": Tag.all.map(&:name)} }
  end

end
