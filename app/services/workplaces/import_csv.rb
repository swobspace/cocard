require 'csv'
module Workplaces
  class ImportCSV
    include BooleanHelper
    Result = ImmutableStruct.new( :success?, :error_messages, :workplaces )

    # service = Workplaces::ImportCSV.new(file: 'csvfile', ...)
    #
    # mandatory options:
    # * :file   - csv import file
    #
    # optional parameters:
    # * :update_only (boolean) - don't create new records
    # * :force_update (boolean) - overwrite description
    #
    def initialize(options = {})
      options.symbolize_keys!
      @csvfile = get_file(options)
      @update_only  = to_boolean(options.fetch(:update_only, true ))   # safe default
      @force_update = to_boolean(options.fetch(:force_update, false )) # safe default
    end

    # service.call()
    #
    def call
      workplaces = []
      errors = []
      success = true
      unless File.readable?(csvfile)
        errors << "File #{csvfile} is not readable or does not exist"
        return Result.new(success?: false, error_messages: errors, workplaces: [])
      end

      unless check_csv_header
        errors << "CSV Header must be name;description"
        return Result.new(success?: false, error_messages: errors, workplaces: [])
      end

      CSV.foreach(csvfile, headers: true, col_sep: ';',
                           nil_value: "",
                           liberal_parsing: true,
                           converters: :all ) do |row|
        wpc = Workplaces::Creator.new(attributes: row.to_hash, update_only: update_only,
                                     force_update: force_update)
        next unless wpc.processable?
        if wpc.save
          workplaces << wpc.workplace
        else
          if wpc.workplace.errors.any?
            errors << "#{wpc.workplace.errors.full_messages.join(', ')}" 
          end
          success = false
        end
      end
      return_result =  Result.new(success?: success, error_messages: errors,
                                  workplaces: workplaces)
    end

  private
    attr_reader :csvfile, :force_update, :update_only

    # file may be ActionDispatch::Http::UploadedFile
    #
    def get_file(options)
      file = options.fetch(:file)
      if file.respond_to?(:path)
        file.path
      else
        file.to_s
      end
    end

    def check_csv_header
      line = File.open(csvfile) {|f| f.readline}
      !!(line =~ /\Aname;description/)
    end

  end
end
