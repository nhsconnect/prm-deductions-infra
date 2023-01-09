require 'json'

# Rename parameter store paths. Takes:
# - parameter store json file path
# - old path
# - new path to use
old_path, new_path, _rest = ARGV
params = `aws ssm get-parameters-by-path --path #{old_path} --with-decryption --region "eu-west-2"`
puts params
params = JSON.parse(params, object_class: OpenStruct)
puts old_path
puts new_path
puts params
params.Parameters.each do |param|
  name = param.Name.gsub(old_path, new_path)
  value = param.Value.gsub(old_path, new_path)
  type = param.Type
  oldName = param.Name

  json_body = {"Name" => name, "Value" => value, "Type" => type }.to_json
  puts json_body
  # Assumes default KMS key for 'SecureString' type.
  output = `aws ssm put-parameter --region "eu-west-2" --cli-input-json '#{json_body}'`
  puts output.to_json
  puts oldName
  puts name
#    deleteOldParams = `aws ssm delete-parameters --region "eu-west-2" --names #{old_path} + #{oldName}`
#    puts deleteOldParams.to_json
end

