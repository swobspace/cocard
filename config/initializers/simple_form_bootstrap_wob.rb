SimpleForm.setup do |config|
  config.wrappers :horizontal_date, tag: 'div', class: 'mb-3 row', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :pattern
    b.optional :readonly
    b.use :label, class: 'col-sm-3 form-control-label'

    b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-3' do |ba|
      ba.use :input, class: 'form-control', type: 'date', autocomplete: 'off', error_class: 'is-invalid', valid_class: 'is-valid'

      ba.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }

    end
  end

  config.wrappers :horizontal_select, tag: 'div', class: 'mb-3 row', error_class: 'form-group-invalid', valid_class: 'form-group-valid' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :pattern
    b.optional :readonly
    b.use :label, class: 'col-sm-3 form-control-label'

    b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid', data: { controller: :select }
      ba.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }

    end
  end

  config.wrappers :horizontal_short, tag: 'div', class: 'mb-3 row', 
                  error_class: 'form-group-invalid', 
                  valid_class: 'form-group-valid' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'col-sm-3 col-form-label'
    b.wrapper :grid_wrapper, tag: 'div', class: 'col-sm-3' do |ba|
      ba.use :input, class: 'form-control', error_class: 'is-invalid', valid_class: 'is-valid'
      ba.use :full_error, wrap_with: { tag: 'div', class: 'invalid-feedback' }
      ba.use :hint, wrap_with: { tag: 'small', class: 'form-text text-muted' }
    end
  end

end
