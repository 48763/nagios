# nagios
 
Nagios 是電腦系統和網絡監控程序，用於檢測主機和服務，當異常發生和解除時能提醒用戶；是基於GPLv2開發的開源軟體，可免費獲得及使用。[1]

## Clone

```
$ git clone https://github.com/48763/nagios.git
$ cd nagios
```

## 安裝

提供兩種安裝方式：

- 本機
- Docker

### 本機

#### 腳本支援系統

| 系統 | 版本 |
| - | - |
| Ubuntu | trusty |
| | utopic |
| | vivid |
| | wily |
| | xenial |
| | yakkety |
| | zesty |
| | artful |
| | bionic |
| | cosmic |
| | focal |
| CentOS | 5 |
| | 6 |
| | 7 |
| | 8 |

- Ubuntu
    - trusty
    - utopic
    - vivid
    - wily
    - xenial
    - yakkety
    - zesty
    - artful
    - bionic
    - cosmic
    - focal
- CentOS
    - 5
    - 6
    - 7
    - 8

```
$ ./init.sh
```

### Docker

```
$ cd docker
$ ./run.sh
```

## 參考

[wiki](https://zh.wikipedia.org/wiki/Nagios)