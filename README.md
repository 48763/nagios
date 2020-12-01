# nagios
 
Nagios 是電腦系統和網絡監控程序，用於檢測主機和服務，當異常發生和解除時能提醒用戶；是基於GPLv2開發的開源軟體，可免費獲得及使用。[[1]](#參考)

## 簡介

此專案統整了 *Ubuntu* 和 *CentOs* 的安裝流程，製作成腳本 [`init.sh`](#本機)，幫助環境快速搭建，如果想要簡單的快速測試，可以在運行 Docker 的系統中，使用腳本 [`run.sh`](#docker)。

在配置檔，僅需要按照需求編寫 [`url.md`](#urlmd-格式)，以及在 [`conf`](路徑與區域配置) 添加 nagios 安裝路徑，就能使用 [`gen-cfg`](生成配置) 快速生成配置，就能輕鬆控管網頁的*憑證*及*頁面狀態*。

該專案已經有預先寫好範例，僅需安裝好 Docker，並按照下列操作，可以快速的演示：

```
$ git clone https://github.com/48763/nagios.git
$ cd nagois/docker
$ ./run.sh
```

應用服務運行在：

```
http://localhost:80
```

> 應用預設帳密 nagiosadmin/P@ssw0rd

## 安裝

提供以下兩種部署方式：

- [本機](#本機)
- [Docker](#docker)

### 本機

**支援系統：**

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

進入專案後，僅需執行下面指令腳本，就能按照所支援系統及版本安裝應用：

```
$ ./init.sh
```

### Docker

執行下面指令腳本，就能自動建置鏡像及啟用容器：

```
$ cd docker
$ ./run.sh
```

## 配置

該專案提一文件格式以及自動生成配置的腳本，僅需填寫環境要監控的分類及網址，就能用腳本自動生成配置使用。

### `url.md` 格式

按照下面配置 `url.md`（已寫好範例），就能生成配置。 nagios 預設全部用 `https` 訪問網頁。

```
# 區域a

## 專案a

### 環境

#### 子專案

- www.domainA/path
- api.domainB/path

# 區域b

## 專案a

### 環境

- back.domainA
- front.domainB

## nothing-to-do
```

> `####` 是提供給子專案使用，如果專案內沒再細分，可以忽略不使用。

### 路徑與區域配置

將 `project` 目錄複製到 nagios 運行目錄下，僅需配置一次：

```
$ cp -r project /usr/local/nagios/etc/
```

在 `conf` 填寫 nagios 運行目錄位置，以及腳本自動生成配置的區域：

```
$ vi conf
NAGIOS_PATH="/usr/local/nagios/etc/project"
NEEDREGION="region-a,region-b"
```

> NEEDREGION：腳本會按照所填寫的區域名稱，生成該區域的配置。

### 生成配置

執行該腳本，就能將配置檔按照路徑生成：

```
$ ./gen-cfg
```

## 參考

[Wikipedia, Nagios, English](https://zh.wikipedia.org/wiki/Nagios)