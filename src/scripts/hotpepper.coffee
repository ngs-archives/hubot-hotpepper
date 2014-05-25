# Description:
#   Searches restaurants with Hotpepper.
#
# Commands:
#   hubot ご飯 <query> - ご飯検索
#   hubot ランチ <query> - ランチ検索
#   hubot 酒 <query> - 日本酒が充実なお店検索
#   hubot 焼酎 <query> - 焼酎が充実なお店検索
#   hubot ワイン <query> - ワインが充実してるお店検索
#   hubot カラオケ <query> - カラオケができるお店検索
#   hubot 夜食 <query> - 23 時以降に食事ができるお店検索
#   hubot 飲み放題 <query> - 飲み放題のお店検索
#   hubot 食べ放題 <query> - 食べ放題のお店検索

_       = require 'underscore'
API_KEY = process.env.HUBOT_RWS_API_KEY

module.exports = (robot) ->

  hprSearch = (msg, conditions)->
    query = _.extend {
      key: API_KEY
      keyword: msg.match[3]
      count: 100
      format: 'json'
    }, conditions
    robot.http("http://webservice.recruit.co.jp/hotpepper/gourmet/v1/")
      .query(query).get() (err, res, body) ->
        return msg.send err if err
        shop = _.shuffle(JSON.parse(body).results.shop)[0]
        return msg.send 'Not found' unless shop
        img  = shop.photo.pc.l + '#.png'
        name = shop.name
        addr = shop.address
        url  = shop.urls.pc
        msg.send img
        msg.send [name, addr, url].join "\n"

  robot.respond /(hotpepper|gourmet|ご飯)( me)? (.*)/i, (msg) ->
    hprSearch msg, {}

  robot.respond /(lunch|ランチ)( me)? (.*)/i, (msg) ->
    hprSearch msg, { lunch: 1 }

  robot.respond /(sake|酒|日本酒)( me)? (.*)/i, (msg) ->
    hprSearch msg, { sake: 1 }

  robot.respond /(shochu|焼酎)( me)? (.*)/i, (msg) ->
    hprSearch msg, { shochu: 1 }

  robot.respond /(wine|ワイン)( me)? (.*)/i, (msg) ->
    hprSearch msg, { wine: 1 }

  robot.respond /(karaoke|カラオケ)( me)? (.*)/i, (msg) ->
    hprSearch msg, { karaoke: 1 }

  robot.respond /(midnight\s*meal|夜食)( me)? (.*)/i, (msg) ->
    hprSearch msg, { midnight_meal: 1 }

  robot.respond /(free\s*drink|飲み放題)( me)? (.*)/i, (msg) ->
    hprSearch msg, { free_drink: 1 }

  robot.respond /(free\s*food|食べ放題)( me)? (.*)/i, (msg) ->
    hprSearch msg, { free_food: 1 }

