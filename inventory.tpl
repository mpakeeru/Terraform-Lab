[vprofile-appservers]
%{ for ip in web_servers ~}
${ip}
%{ endfor ~}

[vprofile-memecache]
%{ for ip in memcache_servers ~}
${ip}
%{ endfor ~}

[vprofile-dbservers]
%{ for ip in db_servers ~}
${ip}
%{ endfor ~}

[vprofile-mqservers]
%{ for ip in mq_servers ~}
${ip}
%{ endfor ~}