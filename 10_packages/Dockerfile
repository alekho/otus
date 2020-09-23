FROM centos:centos7

WORKDIR /root

RUN yum install rpmdevtools rpm-build tree yum-utils  wget gcc make  -y -q
RUN wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.8.1-1.el7.ngx.src.rpm
RUN rpm -i nginx-1.8.1-1.el7.ngx.src.rpm
RUN sed -i '82a\BuildRequires: GeoIP-devel' /root/rpmbuild/SPECS/nginx.spec
RUN sed -i '136a\        --with-http_geoip_module\\' /root/rpmbuild/SPECS/nginx.spec
RUN sed -i '176a\        --with-http_geoip_module\\' /root/rpmbuild/SPECS/nginx.spec
RUN yum-builddep rpmbuild/SPECS/nginx.spec -y 
RUN rpmbuild -bb rpmbuild/SPECS/nginx.spec
RUN yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.8.1-1.el7.ngx.x86_64.rpm

EXPOSE 80 

CMD ["nginx", "-g", "daemon off;"]
