#!/usr/bin/env ruby

# created by Eliezer Croitoru at 20201028 20:05.
#
# NgTech LTD, 3-Clause BSD License

require "httparty"
require "digest/md5"

response_size_limit = 2000000

output = "OK"
status_code = 0
debug = 0

if ARGV.size < 2
  puts "Missing Arguments"
  exit 1
end

request_url = ARGV[0]
expected_hash = ARGV[1]

begin
  head_response = HTTParty.head(request_url, follow_redirects: true, maintain_method_across_redirects: true)
rescue => e
  output = "Failed to download the file"
  STDERR.puts e if debug > 0
  STDERR.puts e.inspect if debug > 0
  status_code = 1
end

if head_response == nil or !head_response.success?
  output = "WARNING Error downloading the File"
  status_code = 1
end

if status_code == 0
  if head_response.headers["content-length"].to_i > response_size_limit
    output = "File size is too big"
    status_code = 1
  end

  begin
    response = HTTParty.get(request_url, follow_redirects: true, maintain_method_across_redirects: true)
    if response == nil or !response.success? or response.code != 200
      output = "WARNING Error while downloading the file"
      status_code = 1
    end

    url_hash = Digest::MD5.hexdigest(response.body)
    if url_hash.to_s == expected_hash.to_s
      output = "OK - #{url_hash} == #{expected_hash}"
    else
      if url_hash.size == expected_hash.size
        output = "WARNING - HASH => \"#{url_hash}\"  !=  EXPECTED => \"#{expected_hash}\""
      else
        output = "WARNING - Different HASH length - HASH => \"#{url_hash}\" != EXPECTED => \"#{expected_hash}\""
      end
    end
  rescue => e
    output = "Failed to download the file"
    STDERR.puts e if debug > 0
    STDERR.puts e.inspect if debug > 0
    status_code = 1
  end
end

puts(output)
exit(status_code)
