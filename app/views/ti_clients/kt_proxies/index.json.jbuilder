json.proxies do
  json.array! @kt_proxies, partial: 'kt_proxies/kt_proxy', as: :kt_proxy
end
