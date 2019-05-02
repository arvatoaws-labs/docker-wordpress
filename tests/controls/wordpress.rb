# encoding: utf-8
# copyright: 2019, Arvato Systems GmbH

title 'wordpress tests'

# wait for application startup
puts "Waiting 15s for application startup"
sleep 15

# you add controls here
control "http-1.0" do                                   # A unique ID for this control
  impact 0.7                                           # The criticality, if this control fails.
  title "Generic http tests againt nginx container"                        # A human-readable title
  tag data: "http"                                # A tag allows you to associate key information

  describe http('http://nginx') do
    its('status') { should cmp 301 }
  end

  describe http('https://nginx', ssl_verify: false) do
    its('status') { should cmp 301 }
  end
  
end

# you add controls here
control "wordpress-1.0" do                                   # A unique ID for this control
  impact 0.7                                           # The criticality, if this control fails.
  title "Contao specific tests againt nginx container"                        # A human-readable title
  tag data: "http"                                # A tag allows you to associate key information

  describe http('https://nginx', ssl_verify: false) do
    its('status') { should cmp 301 }
    its('headers.Location') { should cmp 'https://nginx/en/' }
  end

  describe http('https://nginx/en/elements.html', ssl_verify: false) do
    its('status') { should cmp 200 }
    its('body') { should include '<a class="logo"' }
  end

  describe http('https://nginx/wordpress/login', ssl_verify: false) do
    its('status') { should cmp 200 }
    its('body') { should include 'Login' }
  end
  
  # describe http('https://nginx/sitemap-en.xml', ssl_verify: false) do
  #   its('status') { should cmp 200 }
  #   its('body') { should include 'www.sitemaps.org' }
  # end
  
  describe http('https://nginx/files/products/docs/daimler_freigabeliste_integra_we.xlsx', ssl_verify: false) do
    its('status') { should cmp 200 }
  end  
  
  # describe http('https://nginx/de/files/products/docs/daimler_freigabeliste_integra_we.xlsx', ssl_verify: false) do
  #   its('status') { should cmp 200 }
  # end
  
end