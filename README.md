# Drawtle

##説明
描いて欲しいイラストはあるが自分で描けない人と，イラストを描きたいが何を描けば良いか戸惑っている人がマッチングされるiOSアプリを作成しました．

##言語，ライブラリ
使用した言語は「Swift」です．
使用したライブラリは「SDWebImage」「Alamofire」です．

##工夫した点
###画像のキャッシュ
画像を素早く表示させるために画像をキャッシュして，次回からの表示スピードを速めています．これはSDWebImageというライブラリを用いて画像のキャッシュを行っています．
###サーバとの通信
画像を保存しているサーバとの通信が必要になったので，Alamofireというライブラリを使って素早く理解しやすいコードを作成しました．
###ホーム画面
どのようなイラストが投稿されていて，どのように盛り上がっているのかがホーム画面を表示した時にある程度理解できるようにするために各お題につき3つまでイラストを表示するデザインにしました．
![ホーム画面](https://github.com/yoshiya12x/Images/blob/master/Drawtle_image/top.png)
###通知機能とブックマーク機能
投稿したイラストやお題に反応があった時にその旨が通知される仕様になっています．これによりお題を投稿した人は随時アプリをチェックする手間がなくなり，また，ブックマークやファボされたことが分かると投稿した報酬を得たことになり，よりアプリの利用率が高くなると考えます．そして，気に入ったお題を保存できるブックマーク機能があります．投稿されたお題は新しいものから順に表示され，過去のものは流れていきます．よって気に入ったお題を保存しておくためのブックマーク機能を作成しました．

![通知機能](https://github.com/yoshiya12x/Images/blob/master/Drawtle_image/mention.png)
![ブックマーク機能](https://github.com/yoshiya12x/Images/blob/master/Drawtle_image/bookmark.png)
