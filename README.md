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

**腳本支援系統**

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

## 配置

### `url.md` 格式

```
# 區域a

## 專案a

### 環境

#### 子專案

# 區域b

## 專案a

### 環境

#### 子專案

## nothing-to-do
```

### 路徑與區域配置

```
$ cp -r project /usr/local/nagios/etc/
$ vi conf
NAGIOS_PATH="./project"
NEEDREGION="region-a,region-b"
```

### 生成配置

```
$ ./gen-cfg
```

## 參考

[wiki](https://zh.wikipedia.org/wiki/Nagios)