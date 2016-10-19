require 'net/http'
require 'json'
require 'uri'

# get token at https://api.slack.com/docs/oauth-test-tokens
@token = ''
userHash = {}

def list_files
  ts_to = (Time.now - 180 * 24 * 60 * 60).to_i # 180 days ago
  params = {
    token: @token,
    ts_to: ts_to,
    types: 'images',
    count: 1000
  }
  uri = URI.parse('https://slack.com/api/files.list')
  uri.query = URI.encode_www_form(params)
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)['files']
end

def users_info(user_id)
  params = {
    token: @token,
    user: user_id
  }
  uri = URI.parse('https://slack.com/api/users.info')
  uri.query = URI.encode_www_form(params)
  response = Net::HTTP.get_response(uri)
  return JSON.parse(response.body)['user']['name']
end

def delete_files(file_ids)
  file_ids.each do |file_id|
    params = {
      token: @token,
      file: file_id
    }
    uri = URI.parse('https://slack.com/api/files.delete')
    uri.query = URI.encode_www_form(params)
    response = Net::HTTP.get_response(uri)
    p "#{file_id}: #{JSON.parse(response.body)['ok']}"
  end
end

p 'List files...'
files = list_files
file_ids = files.map { |f| f['id'] }
# p file_ids

# query user name
files.each do |f|
  id = f['user']
  if !userHash[id] then
    userHash[id] = users_info(id)
  end
end

file_names = files.map { |f| userHash[f['user']] + " : " +  f['filetype'] + " => " + f['title'] }
puts file_names

p 'Deleting files...'
delete_files(file_ids)
