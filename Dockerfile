FROM --platform=linux/arm64/v8 ubuntu AS baseline

#Build for arm64 
#Original from
#LABEL maintainer="Arsenio Aguirre" \
#      email="a_aguirre117@hotmail.com"
#
LABEL maintainer="DEEN"


RUN apt-get update && \
    DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata

# Install packages
RUN \
    apt-get update && \
    apt-get install -y \
    traceroute \
    whois \
    host \
    htop \
    dnsutils \
    net-tools \
    figlet \
    tcpdump \
    telnet \
    prips \
    cifs-utils \
    rlwrap \
    iputils-ping \
    git \
    xsltproc \
    rdate \
    zsh \
    curl \
    unzip \
    p7zip-full \
    locate \
    tree \
    openvpn \
    vim \
    wget \
    ftp \
    apache2 \
    squid \
    python3 \
    python3-pip \
    jq \
    libcurl4-openssl-dev \
    libssl-dev \
    nmap \
    masscan \
    nikto \
    netcat \
    cewl \
    crunch \
    hydra \
    medusa \
    pocl-opencl-icd \
    libwww-perl \
    chromium-browser \
    dos2unix \
    openjdk-8-jdk \
    ssh \
    rsyslog \
    fcrackzip \
    texlive-full \
    latexmk \
    exiftool \
    steghide \
    binwalk \
    foremost \
    sqlite3 \
    # patator dependencies
    libmysqlclient-dev \
    # evil-winrm dependencies
    ruby-full \
    # enum4linux dependencies
    ldap-utils \
    smbclient \
    # cracking
    hashcat \
    # john dependencies
    build-essential \
    libssl-dev \
    zlib1g-dev  \
    yasm \
    pkg-config \
    libgmp-dev \
    libpcap-dev \
    libbz2-dev \
    # crackmapexec dependencies
    libffi-dev \
    python-dev && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y php \
    libapache2-mod-php && \
    gem install \
    gpp-decrypt \
    addressable \
    wpscan \
    # Install evil-winrm
    evil-winrm && \
    apt-get update

RUN python3 -m pip install --upgrade pip

FROM baseline as builder
# SERVICES

# Apache configuration
RUN \
    sed -i 's/It works!/It works form container!/g' /var/www/html/index.html && \
# Squid configuration
    echo "http_access allow all" >> /etc/squid/squid.conf && \
    sed -i 's/http_access deny all/#http_access deny all/g' /etc/squid/squid.conf && \
# OS TOOLS
# Install oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    sed -i '1i export LC_CTYPE="C.UTF-8"' /root/.zshrc && \
    sed -i '2i export LC_ALL="C.UTF-8"' /root/.zshrc && \
    sed -i '3i export LANG="C.UTF-8"' /root/.zshrc && \
    sed -i '3i export LANGUAGE="C.UTF-8"' /root/.zshrc && \
    git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search /root/.oh-my-zsh/custom/plugins/zsh-history-substring-search && \
    sed -i 's/plugins=(git)/plugins=(git aws golang nmap node pip pipenv python ubuntu zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search)/g' /root/.zshrc && \
    sed -i '78i autoload -U compinit && compinit' /root/.zshrc

# Install python dependencies
COPY requirements_pip.txt /tmp
RUN \
    pip install -r /tmp/requirements_pip.txt

# DEVELOPER TOOLS

# Install go
WORKDIR /tmp
RUN \
# Update from 1.15.5 to 1.16.2
#    wget -q https://dl.google.com/go/go1.15.5.linux-amd64.tar.gz -O go.tar.gz && \
    wget -q https://go.dev/dl/go1.17.5.linux-arm64.tar.gz -O go.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
# Install aws-cli
    #curl https://awscli.amazonaws.com/awscli-exe-linux-arm64.zip -o awscliv2.zip && \
    curl https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    ./aws/install && \
# Install node
    curl -sL https://deb.nodesource.com/setup_14.x | bash && \
    apt install -y nodejs
ENV GOROOT "/usr/local/go"
ENV GOPATH "/root/go"
ENV PATH "$PATH:$GOPATH/bin:$GOROOT/bin"

# PORT SCANNING
RUN mkdir -p /tools/portScanning
WORKDIR /tools/portScanning

#RUN \
# Download naabu
#    mkdir -p /tools/portScanning/naabu
#WORKDIR /tools/portScanning/naabu
#RUN \
#    wget --quiet https://github.com/projectdiscovery/naabu/releases/download/v1.1.4/naabu_1.1.4_linux_amd64.tar.gz -O naabu.tar.gz && \
#    tar -xzf naabu.tar.gz && \
#    rm naabu.tar.gz && \
#    ln -s /tools/portScanning/naabu/naabu /usr/bin/naabu

# BUILDER RECON
FROM baseline as recon
RUN mkdir /temp
WORKDIR /temp/

# Download whatweb
RUN \
    git clone --depth 1 https://github.com/urbanadventurer/WhatWeb.git && \
# Install dirsearch
    git clone --depth 1 https://github.com/maurosoria/dirsearch.git && \
# Download arjun
    git clone --depth 1 https://github.com/s0md3v/Arjun.git && \
# Download joomscan
    git clone --depth 1 https://github.com/rezasp/joomscan.git && \
# Install massdns
    git clone --depth 1 https://github.com/blechschmidt/massdns.git && \
# Install striker
    git clone --depth 1 https://github.com/s0md3v/Striker.git && \
# Install Photon
    git clone --depth 1 https://github.com/s0md3v/Photon.git && \
# Download linkfinder
    git clone --depth 1 https://github.com/GerbenJavado/LinkFinder.git && \
# Downlado CMSeeK
    git clone --depth 1 https://github.com/Tuhinshubhra/CMSeeK.git && \
# Install aquatone
    #wget --quiet https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_amd64_1.7.0.zip -O aquatone.zip && \
    wget --quiet https://github.com/michenriksen/aquatone/releases/download/v1.7.0/aquatone_linux_arm64_1.7.0.zip -O aquatone.zip && \
    unzip aquatone.zip -d aquatone  && \
    rm aquatone.zip && \
# Install amass
    #wget --quiet https://github.com/OWASP/Amass/releases/download/v3.10.5/amass_linux_amd64.zip -O amass.zip && \
    wget --quiet https://github.com/OWASP/Amass/releases/download/v3.10.5/amass_linux_arm64.zip -O amass.zip && \
    unzip amass.zip -d amass && \
    rm amass.zip && \
# Download Sublist3r
    git clone --depth 1 https://github.com/aboul3la/Sublist3r.git && \
# Download spiderfoot
    git clone --depth 1 https://github.com/smicallef/spiderfoot && \
    mkdir /temp/gowitness && \
    mkdir /temp/subfinder && \
    mkdir /temp/findomain && \
    mkdir /temp/gau && \
    mkdir /temp/httpx && \
    mkdir /temp/subjs

WORKDIR /temp/Photon
RUN \
    chmod +x photon.py && \
    dos2unix photon.py

WORKDIR /temp/CMSeeK
RUN \
    mkdir Result && \
    chmod +x cmseek.py

# Download gowitness
#WORKDIR /temp/gowitness
#RUN \
    #wget --quiet https://github.com/sensepost/gowitness/releases/download/1.3.4/gowitness-linux-amd64 -O gowitness && \
#    wget --quiet https://github.com/sensepost/gowitness/releases/download/1.3.4/gowitness-linux-arm64 -O gowitness && \
#    chmod +x gowitness

# Download findomain
WORKDIR /temp/findomain
RUN \
    wget --quiet https://github.com/Edu4rdSHL/findomain/releases/download/2.1.1/findomain-linux -O findomain && \
    chmod +x findomain

# Download subfinder
WORKDIR /temp/subfinder
RUN \
    #wget --quiet https://github.com/projectdiscovery/subfinder/releases/download/v2.4.5/subfinder_2.4.5_linux_amd64.tar.gz -O subfinder.tar.gz && \
    wget --quiet https://github.com/projectdiscovery/subfinder/releases/download/v2.4.9/subfinder_2.4.9_linux_arm64.zip -O subfinder.zip && \
    #tar -xzf subfinder.tar.gz && \
    #rm subfinder.tar.gz
    unzip subfinder.zip -d subfinder && \
    rm subfinder.zip 

# Download gau
#WORKDIR /temp/gau
#RUN \
#    wget --quiet https://github.com/lc/gau/releases/download/v1.0.3/gau_1.0.3_linux_amd64.tar.gz -O gau.tar.gz && \
#    tar -xzf gau.tar.gz && \
#    rm gau.tar.gz

# Download subjs
#WORKDIR /temp/subjs
#RUN \
#    wget --quiet https://github.com/lc/subjs/releases/download/v1.0.1/subjs_1.0.1_linux_amd64.tar.gz -O subjs.tar.gz && \
#    tar -xzf subjs.tar.gz && \
#    rm subjs.tar.gz

# Download httpx
WORKDIR /temp/httpx
RUN \
    #wget --quiet https://github.com/projectdiscovery/httpx/releases/download/v1.0.1/httpx_1.0.1_linux_amd64.tar.gz -O httpx.tar.gz && \
    wget --quiet https://github.com/projectdiscovery/httpx/releases/download/v1.1.4/httpx_1.1.4_linux_arm64.zip -O httpx.zip && \
    unzip httpx.zip -d httpx && \
    rm httpx.zip 

# RECON
FROM builder as builder2
COPY --from=recon /temp/ /tools/recon/
WORKDIR /tools/recon

# Install gobuster
RUN \
    go install github.com/OJ/gobuster@latest && \
# Install tojson
    go install github.com/tomnomnom/hacks/tojson@latest && \
# Install gowitness
    ln -s /tools/recon/gowitness/gowitness /usr/bin/gowitness && \
# Install subjack
    go install github.com/haccer/subjack@latest && \
# Install SubOver 
    go install github.com/Ice3man543/SubOver@latest && \
# Install tko-subs
    go install github.com/anshumanbh/tko-subs@latest && \
# Install hakcheckurl
    go install github.com/hakluke/hakcheckurl@latest && \
# Install haktldextract
    go install github.com/hakluke/haktldextract@latest && \
# Install gotop
    go install github.com/cjbassi/gotop@latest && \
# Install aquatone
    ln -s /tools/recon/aquatone/aquatone /usr/bin/aquatone && \
# Install knock
    git clone --depth 1 https://github.com/guelfoweb/knock.git && \
# Install whatweb
    ln -s /tools/recon/WhatWeb/whatweb /usr/bin/whatweb && \
# Install CMSeek
    ln -s /tools/recon/CMSeeK/cmseek.py /usr/bin/cmseek && \
# Install Photon
    ln -s /tools/recon/Photon/photon.py /usr/bin/photon && \
# Install gau
    ln -s /tools/recon/gau/gau /usr/bin/getallurls && \
# Install subjs
    ln -s /tools/recon/subjs/subjs /usr/bin/subjs && \
# Install otxurls
    go install github.com/lc/otxurls@latest && \
# Install amass
    ln -s /tools/recon/amass/amass_linux_amd64/amass /usr/bin/amass && \
# Install hakrevdns
    go install github.com/hakluke/hakrevdns@latest && \
# Install ffuf
    go install github.com/ffuf/ffuf@latest && \
# Install httprobe
    go install github.com/tomnomnom/httprobe@latest && \
# Install hakrawler
    go install github.com/hakluke/hakrawler@latest && \
# Install waybackurls
    go install github.com/tomnomnom/waybackurls@latest && \
# Download gospider
    go install github.com/jaeles-project/gospider@latest && \
# Download getJS
    go install github.com/003random/getJS@latest && \
# Download gitrob
    #go install github.com/michenriksen/gitrob@latest && \
# Install findomain
    ln -s /tools/recon/findomain/findomain /usr/bin/findomain && \
# Install subfinder
    ln -s /tools/recon/subfinder/subfinder /usr/bin/subfinder && \
# Install sublist3r
    ln -s /tools/recon/Sublist3r/sublist3r.py /usr/bin/sublist3r && \
# Install httpx
    ln -s /tools/recon/httpx/httpx /usr/bin/httpx

WORKDIR /tools/recon/knock
RUN python3 setup.py install

# Install linkfinder
WORKDIR /tools/recon/LinkFinder
RUN \
    python3 setup.py install && \
    pip install -r requirements.txt

# Install spiderfoot
WORKDIR /tools/recon/spiderfoot
RUN pip install -r requirements.txt

# BUILDER WORDLIST
FROM baseline as wordlist
RUN mkdir /temp
WORKDIR /temp

# Download wordlists
RUN \
    git clone --depth 1 https://github.com/xmendez/wfuzz.git && \
    git clone --depth 1 https://github.com/danielmiessler/SecLists.git && \
    git clone --depth 1 https://github.com/fuzzdb-project/fuzzdb.git && \
    git clone --depth 1 https://github.com/daviddias/node-dirbuster.git && \
    git clone --depth 1 https://github.com/v0re/dirb.git && \
    curl -L -o rockyou.txt https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt && \
    curl -L -o all.txt https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt && \
    curl -L -o fuzz.txt https://raw.githubusercontent.com/Bo0oM/fuzz.txt/master/fuzz.txt

# WORDLIST
FROM builder2 as builder3
COPY --from=wordlist /temp/ /tools/wordlist/

# BUILDER GIT REPOSITORIES
FROM baseline as gitrepositories
RUN mkdir /temp
WORKDIR /temp

# Download gitGrabber
RUN \
    # git clone --depth 1 https://github.com/hisxo/gitGraber.git && \
# Install gitrob
    #wget --quiet https://github.com/michenriksen/gitrob/releases/download/v2.0.0-beta/gitrob_linux_amd64_2.0.0-beta.zip -O gitrob.zip && \
    #unzip gitrob.zip -d gitrob && \
    #rm gitrob.zip && \
# Install gitleaks
    wget --quiet https://github.com/zricethezav/gitleaks/releases/download/v8.2.5/gitleaks_8.2.5_linux_arm64.tar.gz -O gitleaks && \
    chmod +x gitleaks && \
# Download github-search
    git clone --depth 1 https://github.com/gwen001/github-search.git && \
# Download GitTools
    git clone --depth 1 https://github.com/internetwache/GitTools.git

# GIT REPOSITORIES
FROM builder3 as builder4
COPY --from=gitrepositories /temp/ /tools/gitRepositories/

# BUILDER OWASP
FROM baseline as owasp
RUN mkdir /temp
WORKDIR /temp

# Install sqlmap
RUN \
    git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap && \
# Download XSStrike
    git clone --depth 1 https://github.com/s0md3v/XSStrike.git && \
# Download jwt_tool
    git clone --depth 1 https://github.com/ticarpi/jwt_tool.git
# Download dalfox
WORKDIR /temp/dalfox
RUN \
    wget --quiet https://github.com/hahwul/dalfox/releases/download/v2.7.0/dalfox_2.7.0_linux_arm64.tar.gz -O dalfox.tar.gz && \
    tar -xzf dalfox.tar.gz && \
    rm dalfox.tar.gz
# Download jaeles
WORKDIR /temp/jaeles
RUN \
    #wget --quiet https://github.com/jaeles-project/jaeles/releases/download/beta-v0.12/jaeles-v0.12-linux-amd64.zip -O jaeles.zip && \
    wget --quiet https://github.com/jaeles-project/jaeles/releases/download/beta-v0.17/jaeles-v0.17-linux.zip -O jaeles.zip && \
    unzip jaeles.zip && \
    rm jaeles.zip
    #mv jaeles-v0.17-linux jaeles

# OWASP
FROM builder4 as builder5
COPY --from=owasp /temp/ /tools/owasp/
# Install kxss
RUN \
    go install github.com/tomnomnom/hacks/kxss@latest && \
# Install dalfox
    ln -s /tools/owasp/dalfox/dalfox /usr/bin/dalfox && \
# Install jaeles
    ln -s /tools/owasp/jaeles/jaeles /usr/bin/jaeles 

# BUILDER BRUTE FORCE
FROM baseline as bruteForce
RUN mkdir /temp
WORKDIR /temp

# Download crowbar
RUN \
    git clone --depth 1 https://github.com/galkan/crowbar.git && \
# Download patator
    git clone --depth 1 https://github.com/lanjelot/patator.git

# BRUTE FORCE
FROM builder5 as builder6
COPY --from=bruteForce /temp/ /tools/bruteForce/

WORKDIR /tools/bruteForce/crowbar
RUN pip install -r requirements.txt

# BUILDER CRACKING
FROM baseline as cracking
RUN mkdir /temp
WORKDIR /temp
RUN \
#    # Download hashcat
#    wget --quiet https://hashcat.net/files/hashcat-6.1.1.7z -O hashcat.7z && \
#    7z x hashcat.7z && \
#    rm hashcat.7z && \
#    mv hashcat-6.1.1 hashcat && \
    # Download john the ripper
    git clone --depth 1 https://github.com/magnumripper/JohnTheRipper -b bleeding-jumbo john

# CRACKING
FROM builder6 as builder7
COPY --from=cracking /temp/ /tools/cracking/
RUN \
# Install hashcat
    #ln -s /tools/cracking/hashcat/hashcat.bin /usr/bin/hashcat
    cd /tools/cracking/john/src
# Install john the ripper
WORKDIR /tools/cracking/john/src
RUN ./configure && make -s clean && make -sj4

# BUILDER OS ENUMERATION
FROM baseline as osEnumeration
RUN mkdir /temp
WORKDIR /temp

# Download htbenum
RUN git clone --depth 1 https://github.com/SolomonSklash/htbenum.git
WORKDIR /temp/htbenum
RUN \
    chmod +x htbenum.sh && \
    ./htbenum.sh -u

# Download linux smart enumeration
WORKDIR /temp
RUN git clone --depth 1 https://github.com/diego-treitos/linux-smart-enumeration.git
WORKDIR /temp/linux-smart-enumeration
RUN chmod +x lse.sh

# Download linenum
WORKDIR /temp
RUN git clone --depth 1 https://github.com/rebootuser/LinEnum.git
WORKDIR /temp/LinEnum
RUN chmod +x LinEnum.sh

# Download enum4linux
WORKDIR /temp
RUN \
    git clone --depth 1 https://github.com/CiscoCXSecurity/enum4linux.git && \
# Download enum4linx-ng
    git clone https://github.com/cddmp/enum4linux-ng.git && \    
# Download PEASS - Privilege Escalation Awesome Scripts SUITE
    mkdir -p /temp/peass

WORKDIR /temp/peass
RUN \
    wget -q https://github.com/carlospolop/PEASS-ng/releases/download/refs%2Fpull%2F253%2Fmerge/winPEASany_ofs.exe && \
    wget -q https://github.com/carlospolop/PEASS-ng/releases/download/refs%2Fpull%2F253%2Fmerge/winPEASx64_ofs.exe && \
    wget -q https://github.com/carlospolop/PEASS-ng/releases/download/refs%2Fpull%2F253%2Fmerge/winPEASx86_ofs.exe && \
    wget -q https://github.com/carlospolop/PEASS-ng/releases/download/refs%2Fpull%2F253%2Fmerge/winPEAS.bat && \
    wget -q https://github.com/carlospolop/PEASS-ng/releases/download/refs%2Fpull%2F253%2Fmerge/linpeas.sh

# Install smbmap
WORKDIR /temp
RUN \
    git clone --depth 1 https://github.com/ShawnDEvans/smbmap.git && \
# Download pspy
    mkdir -p /temp/pspy

WORKDIR /temp/pspy
RUN \
    wget -q https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy32 && \
    wget -q https://github.com/DominicBreuker/pspy/releases/download/v1.2.0/pspy64 && \
    chmod +x *

# OS ENUMERATION
FROM builder7 as builder8
COPY --from=osEnumeration /temp/ /tools/osEnumeration/
WORKDIR /tools/osEnumeration

# Download Windows Exploit Suggester - Next Generation
RUN git clone --depth 1 https://github.com/bitsadmin/wesng.git
WORKDIR /tools/osEnumeration/wesng
RUN python3 wes.py --update

# BUILDER EXPLOITS
FROM baseline as exploits
RUN mkdir /temp
WORKDIR /temp

# Downlaod MS17-010
RUN \
    git clone --depth 1 https://github.com/worawit/MS17-010.git && \
# Downlaod AutoBlue-MS17-010
    git clone --depth 1 https://github.com/3ndG4me/AutoBlue-MS17-010.git && \
# Download privexchange
    git clone --depth 1 https://github.com/dirkjanm/PrivExchange.git

# EXPLOITS
FROM builder8 as builder9
COPY --from=exploits /temp/ /tools/exploits/
WORKDIR /tools/exploits

# Install searchsploit
RUN \
    git clone --depth 1 https://github.com/offensive-security/exploitdb.git /opt/exploitdb && \
    sed 's|path_array+=(.*)|path_array+=("/opt/exploitdb")|g' /opt/exploitdb/.searchsploit_rc > ~/.searchsploit_rc && \
    ln -sf /opt/exploitdb/searchsploit /usr/local/bin/searchsploit && \
# Install metasploit
    curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall && \
    chmod 755 msfinstall && \
    ./msfinstall && \
    msfupdate

# BUILDER WINDOWS
FROM baseline as windows
RUN mkdir /temp
WORKDIR /temp

# Download crackmapexec
RUN \
    git clone --recursive https://github.com/byt3bl33d3r/CrackMapExec && \
# Download Nishang
    git clone --depth 1 https://github.com/samratashok/nishang.git && \
# Download juicy-potato
    git clone --depth 1 https://github.com/ohpe/juicy-potato.git && \
# Download powersploit
    git clone --depth 1 https://github.com/PowerShellMafia/PowerSploit.git && \
# Download Pass-the-Hash
    git clone --depth 1 https://github.com/byt3bl33d3r/pth-toolkit.git && \
# Download Mimikatz
    wget --quiet https://github.com/gentilkiwi/mimikatz/releases/download/2.2.0-20210810-2/mimikatz_trunk.zip -O mimikatz.zip && \
    unzip mimikatz.zip -d mimikatz && \
    rm mimikatz.zip && \
    mkdir netcat && \
    mkdir plink
WORKDIR /temp/netcat
# Download netcat
RUN \
    wget --quiet https://github.com/int0x33/nc.exe/raw/master/nc64.exe -O nc64.exe && \
    wget --quiet https://github.com/int0x33/nc.exe/raw/master/nc.exe -O nc32.exe 
WORKDIR /temp/plink
# Download plink
RUN \
    wget --quiet https://the.earth.li/\~sgtatham/putty/latest/w32/plink.exe -O plink32.exe && \
    wget --quiet https://the.earth.li/\~sgtatham/putty/latest/w64/plink.exe -O plink64.exe

# WINDOWS
FROM builder9 as builder10
RUN mkdir -p /tools/windows
COPY --from=windows /temp/ /tools/windows/

# BUILDER MOBILE
FROM baseline as mobile
RUN mkdir /temp
WORKDIR /temp

RUN \
# Download APKTOOL
    wget --quiet https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O apktool && \
    chmod +x apktool && \
    wget --quiet https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.4.1.jar -O apktool.jar && \
    chmod +x apktool.jar

# Mobile
FROM builder10 as builder11
COPY --from=mobile /temp/ /usr/local/bin

# OTHER RESOURCES
RUN mkdir -p /tools/otherResources
WORKDIR /tools/otherResources

# Download pentest-tools
RUN \
    git clone --depth 1 https://github.com/gwen001/pentest-tools.git && \
# Download qsreplace
    go install github.com/tomnomnom/qsreplace@latest

# OS TUNNING

COPY shell/ /tmp
# Copy banner
RUN \
    cat /tmp/banner >> /root/.zshrc && \
# Create shortcuts
    cat /tmp/alias >> /root/.zshrc && \
# Copy custom function
    cat /tmp/customFunctions >> /root/.zshrc && \
# Create or update a database used by locate
    updatedb

# Change workdir
WORKDIR /
