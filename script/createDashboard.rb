require 'rest_client'
require 'json'
require 'open-uri'
require 'yaml'
require 'yajl'

def get_random_string(length=3)
  puts "get_random_string started"
  chars = 'abcdefghjkmnpqrstuvwxyz'
  password = ''
  length.times { password << chars[rand(chars.size)] }
  puts "get_random_string finished"
  return password
end


def getSmallJson(iFile)
  puts "getSmallJson started"
  sourceJson = "#{iFile}"
  request = File.read(sourceJson)
  jsonRes = JSON.parse(request)
  puts "getSmallJson finished"
  return jsonRes
end

def getBigJson(iFile)
  puts "getBigJson started"
  sourceJson = File.new("#{iFile}", 'r')
  parser = Yajl::Parser.new
  jsonRes = parser.parse(sourceJson)
  puts "getBigJson finished"
  return jsonRes
end

def createMapping(iMaping, iFile)
  puts "createMapping started"
  puts "request url: http://localhost:9200/#{iMaping}?pretty"
  puts "request params: #{getSmallJson("#{iFile}")}"
  begin
    sess = RestClient.put("http://localhost:9200/#{iMaping}?pretty", File.open('tj.json', 'r'),
                      content_type: 'application/json')
  rescue Exception
  end
  puts "Request to create #{iMaping} mapping was sucessfull with response code #{defined?(sess.code)}"
  puts "createMapping finished"
end

def createDIndPtn(ipatn)
  payload = {"value":"#{ipatn}"}
  RestClient::Request.execute(method: :post, url: "localhost:5601/api/kibana/settings/defaultIndex",
                            payload: payload.to_json, headers: {content_type: 'application/json', "Accept": "application/json, text/plain, */*", "kbn-xsrf": "#{ipatn}", "Connection": "keep-alive"})
end

def createIPT(ipatn)
  payload = {"title":"#{ipatn}","timeFieldName":"@timestamp"}
  begin
  RestClient::Request.execute(method: :post, url: "localhost:9200/.kibana/index-pattern/#{ipatn}/_create",
                            payload: payload.to_json, headers: {content_type: 'application/json'})
  rescue Exception
  end
end

def createIP(ipatn)
  payload = {"title":"#{ipatn}"}
  begin
  RestClient::Request.execute(method: :post, url: "localhost:9200/.kibana/index-pattern/#{ipatn}/_create",
                            payload: payload.to_json, headers: {content_type: 'application/json'})
  rescue Exception
  end
end

def createSavObj(obj_id, iType, iFile)

  # payload = {"attributes":{"title":"automation-search-avg_balance_acc","description":"","hits":0,"columns":["_source"],"sort":["_score","desc"],"kibanaSavedObjectMeta":{"searchSourceJSON":"{\"index\":\"ba*\",\"query\":{\"match_all\":{}},\"filter\":[]}"}}}
  begin
  RestClient::Request.execute(method: :post, url: "localhost:5601/api/saved_objects/#{iType}/#{obj_id}",
                            payload: getSmallJson(iFile).to_json, headers: {content_type: 'application/json', "kbn-xsrf": "#{obj_id}"})
  rescue Exception
  end
end

# wait for container to be up, adding sleep to allow startup time
sleep(80)

# 1.Create the mapping
puts "Executing task 1: Creating mapping(s) for uploading Index"

createMapping("shakespeare", 'shak.json')
createMapping("logstash-2015.05.18", 'log18.json')
createMapping("logstash-2015.05.19", 'log19.json')
createMapping("logstash-2015.05.20", 'log20.json')

# 2.Create/upload Indexes
RestClient.post("localhost:9200/bank/account/_bulk?pretty", File.open('accounts.json', 'r'), content_type: "application/x-ndjson")
RestClient.post("localhost:9200/shakespeare/doc/_bulk?pretty", File.open('shakespeare_6.0.json', 'r'), content_type: "application/x-ndjson")
RestClient.post("localhost:9200/_bulk?pretty", File.open('logs.jsonl', 'r'), content_type: "application/x-ndjson")

# 3. List all the indices
list_indices = RestClient.get 'localhost:9200/_cat/indices?v'
puts list_indices.body

# 4. Create the logstash index pattern
createIPT("logstash-*")
createDIndPtn("logstash-*")

# 5. Create the shakes* index pattern
createIP("shakes*")

# 6. Create the ba* index pattern
createIP("ba*")

# 7. Create the searches
createSavObj("automation-search-avg_balance_acc", "search", "auto_srch_avg_balance_acc.json")
createSavObj("automation-search-speaker", "search", "auto_srch_speaker.json")
createSavObj("automation-search-breakdown", "search", "auto_srch_byte_breakdown.json")

# 8. Create the visualizations
createSavObj("auto_avg_balance_acc", "visualization", "auto_vis_avg_balance_acc.json")
createSavObj("Auto_Speaker_contribution_shakespeare_play", "visualization", "auto_vis_speaker.json")
createSavObj("auto_byte_breakdown", "visualization", "auto_vis_byte_breakdown.json")

# 9. Create the dashboard
createSavObj("auto_dashboard", "dashboard", "auto_dashboard.json")


