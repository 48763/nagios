#!/bin/bash
#set -x

get_distribution() {
    lsb_dist=""
    # Every system that we officially support has /etc/os-release
    if [ -r /etc/os-release ]; then
        lsb_dist="$(. /etc/os-release && echo "$ID")"
    fi
    # Returning an empty string here should be alright since the
    # case statements don't act unless you provide an actual value
    echo "$lsb_dist"
}

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

main() {
    sh_c='sh -c'
    ## Set execute command prefix.
    if [ "$user" != 'root' ]; then
        if command_exists sudo; then
            sh_c='sudo -E sh -c'
        elif command_exists su; then
            sh_c='su -c'
        else
            cat >&2 <<-'EOF'
            Error: this installer needs the ability to run commands as root.
            We are unable to find either "sudo" or "su" available to make this happen.
			EOF
            exit 1
        fi
    fi

    ## Set linux distribution name
    lsb_dist=$(get_distribution)
    lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

    ## Check linux version
    case "$lsb_dist" in

        ubuntu)
            if command_exists lsb_release; then
                dist_version="$(lsb_release --codename | cut -f2)"
            fi
            if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
                dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
            fi
        ;;

        centos)
            if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
                dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
            fi
        ;;

    esac

    echo "Host's system is $lsb_dist - $dist_version"

    ## Download resource
    cd /tmp

    if [ -f nagioscore.tar.gz ]; then
        wget --no-check-certificate -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.5.tar.gz
        tar xzf nagioscore.tar.gz
    fi

    if [ -f nagios-plugins.tar.gz ]; then
        wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.2.1.tar.gz
        tar zxf nagios-plugins.tar.gz
    fi

    ## Deploy
    case "$lsb_dist" in

        ubuntu)

            $sh_c "apt-get update >/dev/null"
            $sh_c "apt-get install -y apt-utils autoconf gcc libc6 make wget unzip apache2 \
                libmcrypt-dev libssl-dev bc gawk dc build-essential snmp libnet-snmp-perl gettext >/dev/null"

            case "$dist_version" in

                trusty|utopic|vivid|wily)
                    $sh_c "apt-get install -y apache2-utils php5 libgd2-xpm-dev >/dev/null"
                ;;

                xenial|yakkety|zesty|artful)
                    $sh_c "apt-get install -y php libapache2-mod-php7.0 libgd2-xpm-dev >/dev/null"
                ;;

                bionic|cosmic)
                    $sh_c "apt-get install -y php libapache2-mod-php7.2 libgd-dev >/dev/null"
                ;;

                focal)
                    $sh_c "apt-get install -y php libapache2-mod-php7.4 libgd-dev >/dev/null"
                ;;

                *|disco|eoan)
                    echo "Error."
                    exit 1
                ;;

            esac

            cd /tmp/nagioscore-nagios-4.4.5/
            $sh_c "./configure --with-httpd-conf=/etc/apache2/sites-enabled >/dev/null"
            $sh_c "make all >/dev/null"

            $sh_c "make install-groups-users >/dev/null"
            $sh_c "usermod -a -G nagios www-data >/dev/null"

            $sh_c "make install >/dev/null"
            $sh_c "make install-daemoninit >/dev/null"
            $sh_c "make install-commandmode >/dev/null"
            $sh_c "make install-config >/dev/null"
            $sh_c "make install-webconf >/dev/null"

            $sh_c "a2enmod rewrite >/dev/null"
            $sh_c "a2enmod cgi >/dev/null"

            $sh_c "htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin P@ssw0rd >/dev/null"

            cd /tmp/nagios-plugins-release-2.2.1/
            $sh_c "./tools/setup >/dev/null"
            $sh_c "./configure >/dev/null"
            $sh_c "make >/dev/null"
            $sh_c "make install >/dev/null"

            pidof init > /dev/null
            if [ 1 -eq $? ]; then

                if command_exists service; then
                    $sh_c "service apache2 restart >/dev/null"
                    $sh_c "service nagios start >/dev/null"
                fi

            else

                case "$dist_version" in

                    trusty|utopic)
                        $sh_c "service apache2 restart >/dev/null"
                        $sh_c "service nagios start >/dev/null"
                    ;;

                    *)
                        $sh_c "systemctl restart apache2.service >/dev/null"
                        $sh_c "systemctl start nagios.service  >/dev/null"
                    ;;

                esac
            fi

        ;;

        centos)
            
            case "$dist_version" in

                5|6|7)
                    yum install -y gcc glibc glibc-common wget unzip httpd php gd gd-devel perl postfix
                ;;

                8)
                    dnf install -y gcc glibc glibc-common perl httpd php wget gd gd-devel
                    dnf update -y
                ;;
            esac 

            cd /tmp/nagioscore-nagios-4.4.5/
            ./configure
            make all

            make install-groups-users
            usermod -a -G nagios apache

            make install

            case "$dist_version" in

                5|6)
                    make install-daemoninit
                    chkconfig --level 2345 httpd on
                ;;

                7|8)
                    make install-daemoninit
                    systemctl enable httpd.service
                ;;

            esac 

            make install-commandmode
            make install-config
            make install-webconf

            htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

            case "$dist_version" in

                5|6)
                    service httpd start
                    service nagios start
                ;;

                7|8)
                    systemctl start httpd.service
                    systemctl start nagios.service
                ;;

            esac

            case "$dist_version" in

                5)
                    yum install -y gcc glibc glibc-common make gettext automake wget openssl-devel net-snmp net-snmp-utils epel-release
                    yum install -y perl-Net-SNMP
                    cd /tmp
                    wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.60.tar.gz
                    tar xzf autoconf-2.60.tar.gz 
                    cd /tmp/autoconf-2.60
                    ./configure 
                    make
                    make install
                ;;

                6|7)
                    yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release
                    yum install -y perl-Net-SNMP
                ;;

                8)
                    yum install -y gcc glibc glibc-common make gettext automake autoconf wget openssl-devel net-snmp net-snmp-utils epel-release
                    yum --enablerepo=PowerTools,epel install perl-Net-SNMP
                ;;

            esac 

            case "$dist_version" in

                5|6)
                    service nagios start
                    service nagios stop
                    service nagios restart
                    service nagios status
                ;;

                7|8)
                    systemctl start nagios.service
                    systemctl stop nagios.service
                    systemctl restart nagios.service
                    systemctl status nagios.service
                ;;

            esac

        ;;

    esac

}

## Entrypoint
main