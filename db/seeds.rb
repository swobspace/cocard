# frozen_string_literal: true

# -- load YAML config data
config = YAML.load_file(File.join(Rails.root, 'db', 'seeds.yml'))

# -- Roles from yaml(:uniqueness => true)
Wobauth::Role.create(config['roles'])

# -- start with Admin
admin_role = Wobauth::Role.find_by(name: 'Admin')

Wobauth::User.transaction do
  admin = Wobauth::User.find_or_create_by(username: 'admin') do |adm|
    adm.sn = 'Admin'
    adm.givenname = 'Meister'
    adm.password = 'admin9999'
    adm.password_confirmation = 'admin9999'
  end

  Wobauth::Authority.transaction do
    a = Wobauth::Authority.find_or_create_by(authorizable: admin, role: admin_role)
    raise ActiveRecord::Rollback if a.nil?
  end
end

# only for datasets with uniq attribute
[].each do |myklass|
  mytable = myklass.name.underscore.pluralize
  config = YAML.load_file(File.join(Rails.root, 'db', "#{mytable}.yml"))
  myklass.create(config[mytable])
end
