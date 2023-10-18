[appservers]
%{ for ip in app_servers ~}
${ip}
%{ endfor ~}

