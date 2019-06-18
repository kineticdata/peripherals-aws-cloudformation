require File.expand_path(File.join(File.dirname(__FILE__), 'dependencies'))

class AwsCloudFormationDescribeStackResourcesV1

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

    # Retrieve the credentials for the AWS session from the input XML string
    creds = Aws::Credentials.new(@info_values['access_key'], @info_values['secret_key'])

    # Create a base AWS object. This object contains all the methods for accessing
    # Amazon Web Services
    @awsClient = Aws::CloudFormation::Client.new(
      region: @info_values['region'],
      credentials: creds
    )
  end

  def execute()
    xml = '<resources>'

    resp = @awsClient.describe_stack_resources(
      stack_name: @parameters['stack_name'],
    )
    puts resp if @enable_debug_logging

    resp.stack_resources.each do |resource|
      xml << "<resource>"
        unless resource.logical_resource_id.nil? || resource.logical_resource_id == ""
          xml << "<name>" << resource.logical_resource_id << "</name>"
        end
        unless @info_values['region'].nil? || @info_values['region'] == ""
          xml << "<region>" << @info_values['region'] << "</region>"
        end
        unless resource.physical_resource_id.nil? || resource.physical_resource_id == ""
          xml << "<resource_id>" << resource.physical_resource_id << "</resource_id>"
        end
        unless resource.resource_status.nil? || resource.resource_status == ""
          xml << "<status>" << resource.resource_status << "</status>"
        end
        unless resource.timestamp.nil? || resource.timestamp.to_s == ""
          xml << "<timestamp>" << resource.timestamp.to_s << "</timestamp>"
        end
      xml << "</resource>"
    end
    xml << "</resources>"

    puts xml

    puts "Returning results"  if @enable_debug_logging
    <<-RESULTS
    <results>
      <result name="Resource List">#{escape(xml)}</result>
    </results>
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
