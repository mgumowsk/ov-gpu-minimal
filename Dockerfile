FROM centos:7.8.2003 as base_build

ENV http_proxy=http://proxy-ir.intel.com:911
ENV https_proxy=http://proxy-ir.intel.com:912

RUN yum install -y epel-release centos-release-scl && yum update -y && yum install -y \
            boost-atomic \
            boost-chrono \
            boost-filesystem \
            boost-program-options \
            curl \
            devtoolset-8-gcc* \
            libusb \
            ocl-icd \
            unzip \
            wget \
            which \
            && yum clean all

SHELL [ "/usr/bin/scl", "enable", "devtoolset-8" ]
ENV CC=/opt/rh/devtoolset-8/root/bin/gcc
ENV CXX=/opt/rh/devtoolset-8/root/bin/g++


# Set up bazel 
ENV BAZEL_VERSION 2.0.0
WORKDIR /bazel
RUN curl -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36" -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh && \
    chmod +x bazel-*.sh && \
    ./bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

# GPU support:
RUN yum install -y yum-plugin-copr && yum -y copr enable jdanecki/intel-opencl && yum install -y intel-opencl


# install openVINO
ARG DLDT_PACKAGE_URL=http://registrationcenter-download.intel.com/akdlm/IRC_NAS/16803/l_openvino_toolkit_p_2020.4.287_online.tgz
#ARG DLDT_PACKAGE_URL=http://registrationcenter-download.intel.com/akdlm/irc_nas/16670/l_openvino_toolkit_p_2020.3.194_online.tgz
RUN wget $DLDT_PACKAGE_URL && \
    tar -zxf l_openvino_toolkit*.tgz && \
    cd l_openvino_toolkit* && \
    sed -i 's/decline/accept/g' silent.cfg && \
    ./install.sh -s silent.cfg --ignore-signature

COPY drivers/ /drivers
RUN cd /drivers && ./install_NEO_OCL_driver.sh -y
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/intel/openvino/deployment_tools/inference_engine/lib/intel64/:/opt/intel/openvino/deployment_tools/ngraph/lib/
# build project
WORKDIR /build
COPY WORKSPACE .bazelrc /build/
COPY main/ /build/main/
RUN bazel build //main:main

COPY model/ /model/
ENTRYPOINT ["/build/bazel-bin/main/main"]
