require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class AwsCloudFormationCreateStackV1

  def initialize(input)
    # Set the input document attribute
    @input_document = REXML::Document.new(input)

    # Store the info values in a Hash of info names to values.
    @info_values = {}
    REXML::XPath.each(@input_document,"/handler/infos/info") { |item|
      @info_values[item.attributes['name']] = item.text
    }

    # Retrieve all of the handler parameters and store them in a hash attribute
    # named @parameters.
    @parameters = {}
    REXML::XPath.match(@input_document, 'handler/parameters/parameter').each do |node|
      @parameters[node.attribute('name').value] = node.text.to_s
    end

    @enable_debug_logging = @info_values['enable_debug_logging'].downcase == 'yes' ||
                            @info_values['enable_debug_logging'].downcase == 'true'
    puts "Parameters: #{@parameters.inspect}" if @enable_debug_logging

    #Define params used in rest call
    template_parameters_json = !@parameters['template_parameters'].nil?
      ? JSON.parse(@parameters['template_parameters'])
      : {}

    @template_parameters = []
    template_parameters_json.each do |key, value|
      @template_parameters.push({
        parameter_key: key,
        parameter_value: value,
        use_previous_value: true
      })
    end
    puts "Template Parameters: " + @template_parameters.inspect if @enable_debug_logging

    # Retrieve the credentials for the AWS session from the input XML string
    creds = Aws::Credentials.new(@info_values['access_key'], @info_values['secret_key'])

    # Create a base AWS object. This object contains all the methods for accessing
    # Amazon Web Services
    @awsClient = Aws::CloudFormation::Client.new(region: @info_values['region'],credentials: creds)
  end

  def execute()
    resp = @awsClient.create_stack(
      template_url: @parameters['template_url'],
      stack_name: @parameters['stack_name'],
      parameters: @template_parameters
    )

    puts "Returning results - - Stack ID: #{resp.stack_id}"  if @enable_debug_logging

    return <<-RESULTS
    <results>
      <result name="Stack ID">#{resp.stack_id}</result>
    <results />
    RESULTS
  end


  # This is a template method that is used to escape results values (returned in
  # execute) that would cause the XML to be invalid.  This method is not
  # necessary if values do not contain character that have special meaning in
  # XML (&, ", <, and >), however it is a good practice to use it for all return
  # variable results in case the value could include one of those characters in
  # the future.  This method can be copied and reused between handlers.
  def escape(string)
    # Globally replace characters based on the ESCAPE_CHARACTERS constant
    string.to_s.gsub(/[&"><]/) { |special| ESCAPE_CHARACTERS[special] } if string
  end
  # This is a ruby constant that is used by the escape method
  ESCAPE_CHARACTERS = {'&'=>'&amp;', '>'=>'&gt;', '<'=>'&lt;', '"' => '&quot;'}
end
