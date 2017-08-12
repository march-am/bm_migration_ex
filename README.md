# BmMigration

`.env`というファイル名で読書メーターのID/PASSを書く

```
bm_email=hoge@hoge.com
bm_password=fuga
```

以下を実行する

```bash
$ phantomjs --webdriver=5555
$ mix run -e BmMigration.start()
```
