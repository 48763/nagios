# 認證

因為多個 nagios 放在同一域名，僅用 *path* 分隔，變更 cookie 名稱：

```php
vi /usr/local/nagios/share/index.php
#...
	<script LANGUAGE="javascript">
		var n = Math.round(Math.random() * 10000000000);
		document.cookie = "NagMarsFormId=" + n.toString(16);
	</script>
#...
```

> [基本認證][1]：HTTP 沒有為伺服器提供一種方法指示客戶端丟棄這些被快取的金鑰。這意味著伺服器端在使用者不關閉瀏覽器的情況下，並沒有一種有效的方法來讓使用者登出。

## 參考

[1]: https://zh.wikipedia.org/wiki/HTTP基本認證 "Wiki, HTTP基本認證, Chinese"
