ARG GO_VERSION=1.23.2

# https://go.dev/dl/go1.23.2.src.tar.gz
# dnf install -y make dnf-utils rpm-build
# yumdownloader --enablerepo ubi-9-appstream-source --source go
# rpm -iv golang*.src.rpm
# yum-builddep --enablerepo ubi-9-appstream-source golang
# rpmbuild -bs SPECS/…

FROM registry.access.redhat.com/ubi9/ubi@sha256:ee0b908e958a1822afc57e5d386d1ea128eebe492cb2e01b6903ee19c133ea75
WORKDIR /root/rpmbuild
RUN dnf install -y make dnf-utils rpm-build golang
RUN yum-builddep -y --enablerepo ubi-9-appstream-source golang
COPY rpmbuild /root/rpmbuild
RUN rpmbuild -bs SPECS/golang.spec && \
    rpmbuild --rebuild SRPMS/golang*.src.rpm
RUN dnf remove -y golang && \
    dnf install -y openssl-devel
RUN ls -la RPMS/* && \
    rpm -ivh ./RPMS/noarch/golang-src-1.23.2-4.el9.noarch.rpm && \
    rpm -ivh ./RPMS/x86_64/golang-bin-1.23.2-4.el9.x86_64.rpm ./RPMS/x86_64/golang-1.23.2-4.el9.x86_64.rpm && \
    go version && \
    go tool nm /usr/bin/go | grep FIPS
