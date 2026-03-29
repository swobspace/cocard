module ApplicationHelper
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

  def terminal_button_id(unique_id, action)
    return "" if unique_id.nil?
    new_id = unique_id.to_s.gsub(/:/, '')
    "terminal_#{action.to_s}_button_#{new_id}"
  end

  def delete_link(poly, options = {})
    mypoly, obj = get_parts(poly)
    return unless can?(:destroy, obj)
    options.symbolize_keys!

    # soft_deletable?
    if obj.respond_to?(:deleted_at) 
      render SoftDeleteButtonComponent.new(poly: poly)
    else
      # plain rails models
      options = delete_link_defaults.merge(options)
      options[:title] ||= title(obj, :destroy)
      options[:data][:turbo_confirm] ||= confirm_message(obj)
      link_to icon_delete, mypoly, options
    end
  end

  private
    def delete_link_defaults
      { 
        remote: false,
        class: 'btn btn-danger me-1',
        data: { turbo_method: :delete }
      }
    end

end
