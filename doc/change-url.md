# 修改 URL

### nagios

```bash
$ vi /usr/local/nagios/etc/cgi.cfg
url_html_path=/new-path
```

### httpd

```bash
$ vi /etc/httpd/conf.d/nagios.conf
ScriptAlias /new-path/cgi-bin "/usr/local/nagios/sbin"
#...
Alias /new-path "/usr/local/nagios/share"
```

### nagios-cgi

```bash
$ vi /usr/local/nagios/share/config.inc.php
$cfg['cgi_base_url']='/new-path/cgi-bin';
```

### restart

```bash
$ systemctl restart httpd
$ systemctl restart nagios
```