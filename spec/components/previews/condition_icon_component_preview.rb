# spec/components/previews/condition_icon_component_preview.rb
class ConditionIconComponentPreview < ViewComponent::Preview
  def critical
    connector = Connector.new(condition: Cocard::States::CRITICAL)
    render(ConditionIconComponent.new(item: connector))
  end

  def critical_outdated
    connector = Connector.new(condition: Cocard::States::CRITICAL, updated_at: 1.hour.before(Time.current))
    render(ConditionIconComponent.new(item: connector))
  end

  def warning
    connector = Connector.new(condition: Cocard::States::WARNING)
    render(ConditionIconComponent.new(item: connector))
  end

  def unknown
    connector = Connector.new(condition: Cocard::States::UNKNOWN)
    render(ConditionIconComponent.new(item: connector))
  end

  def ok
    connector = Connector.new(condition: Cocard::States::OK)
    render(ConditionIconComponent.new(item: connector))
  end

  def nothing
    connector5 = Connector.new(condition: Cocard::States::NOTHING)
    render(ConditionIconComponent.new(item: connector5))
  end
end
