This installs pyvmomi and Ansible 2.9.10 on CentOS 7. I call my container mothership. You can edit the variables.env file to add any env variables after the container is up and running. If you have a problem wit reaching your company servers from inside the container, try adding the DNS servers manually in /etc/resolv.conf or /etc/hosts after the container is up and running. Also, any changes you make on the folders(volumes) getting mapped will have changes on the otherside.

## USAGE:
To run: docker-compose run mothership