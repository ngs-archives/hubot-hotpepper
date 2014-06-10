hubot-hotpepper
===============

[![Build Status][travis-badge]][travis]
[![npm-version][npm-badge]][npm]

Searches restaurants from Hotpepper with Hubot.

[![](http://ja.ngs.io/images/2014-05-24-hubot-rws/screen.png)][blog]

Commands
--------

```
hubot ご飯 <query> - ご飯検索
hubot ランチ <query> - ランチ検索
hubot 酒 <query> - 日本酒が充実なお店検索
hubot 焼酎 <query> - 焼酎が充実なお店検索
hubot ワイン <query> - ワインが充実してるお店検索
hubot カラオケ <query> - カラオケができるお店検索
hubot 夜食 <query> - 23 時以降に食事ができるお店検索
hubot 飲み放題 <query> - 飲み放題のお店検索
hubot 食べ放題 <query> - 食べ放題のお店検索
```

How to use
----------

1. Grab your API key from [Recruit Web Service] site.
2. Export that onto your `ENV`.

  ```bash
  heroku config:set HUBOT_RWS_API_KEY=$(YOUR_API_KEY)
  ```

3. Add `hubot-hotpepper` to dependency.

  ```bash
  npm install --save hubot-hotpepper
  ```

4. Update `external-scripts.json`.

  ```json
  ["hubot-hotpepper"]
  ```

Author
------

[Atsushi Nagase]

License
-------

[MIT License]

[Recruit Web Service]: http://webservice.recruit.co.jp/
[blog]: http://ja.ngs.io/2014/05/24/hubot-rws/
[Atsushi Nagase]: http://ngs.io/
[MIT License]: LICENSE
[travis-badge]: https://travis-ci.org/ngs/hubot-hotpepper.svg?branch=master
[npm-badge]: http://img.shields.io/npm/v/hubot-hotpepper.svg
[travis]: https://travis-ci.org/ngs/hubot-hotpepper
[npm]: https://www.npmjs.org/package/hubot-hotpepper
