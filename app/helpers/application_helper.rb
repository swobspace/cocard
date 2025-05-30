module ApplicationHelper
  include Pagy::Frontend
  include Wobapphelpers::Helpers::All

  def configuration_active_class
    if Cocard::CONFIGURATION_CONTROLLER.include?(controller.controller_name.to_s)
      "active"
    end
  end

  def tag_list_input(form)
    element = <<~EOFELEMENT
      <div class="row mb-3 string optional">
        #{form.label :tag_list_input,
                     class: "col-sm-3 col-form-label string optional"}
        <div class="col-sm-9">
          #{form.text_field :tag_list_input,
                            class:"string optional w-100 rounded-2",
                            value: form.object.tag_list.to_json,
                            data: { 
                              controller: "tagging",
                              "tagging-options-value": Tag.all.map(&:name)
                            }
           }
        </div>
      </div>
    EOFELEMENT

    element.html_safe
  end

end
