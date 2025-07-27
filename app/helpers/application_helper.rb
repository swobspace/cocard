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

  def copy_link(poly)
    parent, obj = nesting_stuff(poly)
    if can? :copy, obj
      link_to icon_copy, polymorphic_path(poly, action: "copy"),
      :title => t('wobapphelpers.actions.copy', 
                   model: t(obj.class.model_name.to_s.underscore, 
                            scope: 'activerecord.models')), 
      :class => "btn btn-secondary"
    else
      ""
    end
  end

  def nesting_stuff(poly)
    if poly.is_a? Array
      return poly[0], poly[-1]
    else
      return poly, poly
    end
  end


end
