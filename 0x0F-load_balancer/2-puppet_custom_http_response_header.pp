# 2-puppet_custom_http_response_header.pp
# Install Nginx package
package { 'nginx':
  ensure => installed,
}
# Define a custom fact to get the hostname
Facter.add('custom_hostname') do
  setcode 'hostname'
end

# Define a custom HTTP header in the Nginx configuration
file { '/etc/nginx/sites-available/default':
  ensure  => file,
  content => "
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    add_header X-Served-By $::custom_hostname;
}
  ",
  notify  => Service['nginx'],
}

# Ensure Nginx service is running
service { 'nginx':
  ensure  => running,
  enable  => true,
  require => Package['nginx'],
}
