path = require 'path'
Robot = require("hubot/src/robot")
TextMessage = require("hubot/src/message").TextMessage
nock = require 'nock'
process.env.HUBOT_LOG_LEVEL = 'debug'
chai = require 'chai'
chai.use require 'chai-spies'
{ expect, spy } = chai

describe 'hubot-hotpepper', ->
  robot = null
  user = null
  adapter = null
  nockScope = null
  beforeEach (done)->
    process.env.HUBOT_RWS_API_KEY = 'fake-api-key'
    nock.disableNetConnect()
    robot = new Robot null, 'mock-adapter', no
    robot.adapter.on 'connected', ->
      hubotScripts = path.resolve 'node_modules', 'hubot', 'src', 'scripts'
      robot.loadFile path.resolve('.', 'src', 'scripts'), 'hotpepper.coffee'
      robot.loadFile hubotScripts, 'help.coffee'
      user = robot.brain.userForId '1', {
        name: 'ngs'
        room: '#mocha'
      }
      adapter = robot.adapter
      waitForHelp = ->
        if robot.helpCommands().length > 0
          do done
        else
          setTimeout waitForHelp, 100
      do waitForHelp

    do robot.run

  afterEach ->
    nock.cleanAll()
    robot.shutdown()

  describe 'listeners', ->
    it 'should have 10', ->
      expect(robot.listeners).to.have.length 10

  describe 'help', ->
    it 'should have 11', (done)->
      expect(robot.helpCommands()).to.have.length 11
      do done
    it 'should parse help', (done)->
      adapter.on 'send', (envelope, strings)->
        try
          expect(strings[0]).to.equal """
          Hubot help - Displays all of the help commands that Hubot knows about.
          Hubot help <query> - Displays all help commands that match <query>.
          Hubot ご飯 <query> - ご飯検索
          Hubot カラオケ <query> - カラオケができるお店検索
          Hubot ランチ <query> - ランチ検索
          Hubot ワイン <query> - ワインが充実してるお店検索
          Hubot 夜食 <query> - 23 時以降に食事ができるお店検索
          Hubot 焼酎 <query> - 焼酎が充実なお店検索
          Hubot 酒 <query> - 日本酒が充実なお店検索
          Hubot 食べ放題 <query> - 食べ放題のお店検索
          Hubot 飲み放題 <query> - 飲み放題のお店検索
          """
          do done
        catch e
          done e
      adapter.receive new TextMessage user, 'hubot help'

  describe 'error handling', ->
    beforeEach (done)->
      nockScope = nock('http://webservice.recruit.co.jp')
        .get("/hotpepper/gourmet/v1/?key=fake-api-key&keyword=#{encodeURIComponent '西新宿'}&count=100&format=json")
      do done

    afterEach ->
      nockScope = null

    it 'should handle json parse error', (done)->
      nockScope.reply 200, 'foo!'
      adapter.on 'send', (envelope, strings)->
        try
          expect(strings[0]).to.equal 'SyntaxError: Unexpected token o'
          do done
        catch e
          done e
      adapter.receive new TextMessage user, 'hubot gourmet me 西新宿'

    it 'should handle not found', (done)->
      nockScope.reply 200, results: shop: []
      adapter.on 'send', (envelope, strings)->
        try
          expect(strings[0]).to.equal 'Not found'
          do done
        catch e
          done e
      adapter.receive new TextMessage user, 'hubot gourmet me 西新宿'

    it 'should handle exception on request', (done)->
      nockScope.reply 200, -> throw new Error 'foo'
      adapter.on 'send', (envelope, strings)->
        try
          expect(strings[0]).to.equal 'Error: foo'
          do done
        catch e
          done e
      adapter.receive new TextMessage user, 'hubot gourmet me 西新宿'

    it 'should handle json parse error', (done)->
      nockScope.reply 200, 'foo!'
      adapter.on 'send', (envelope, strings)->
        expect(strings[0]).to.equal 'SyntaxError: Unexpected token o'
        do done
      adapter.receive new TextMessage user, 'hubot gourmet me 西新宿'

  describe 'searching restaurants', ->
    [
      ['hubot ご飯   me   西新宿'      , '']
      ['hubot ご飯    西新宿'          , '']
      ['hubot hotpepper   me  西新宿'  , '']
      ['hubot hotpepper    西新宿'     , '']
      ['hubot gourmet  me  西新宿'     , '']
      ['hubot gourmet   西新宿'        , '']
      ['hubot ランチ     西新宿'       , '&lunch=1']
      ['hubot ランチ  me   西新宿'     , '&lunch=1']
      ['hubot lunch     西新宿'        , '&lunch=1']
      ['hubot lunch  me   西新宿'      , '&lunch=1']
      ['hubot sake     西新宿'         , '&sake=1']
      ['hubot sake  me   西新宿'       , '&sake=1']
      ['hubot 酒     西新宿'           , '&sake=1']
      ['hubot 酒  me   西新宿'         , '&sake=1']
      ['hubot 日本酒     西新宿'       , '&sake=1']
      ['hubot 日本酒  me   西新宿'     , '&sake=1']
      ['hubot shochu     西新宿'       , '&shochu=1']
      ['hubot shochu  me   西新宿'     , '&shochu=1']
      ['hubot 焼酎     西新宿'         , '&shochu=1']
      ['hubot 焼酎  me   西新宿'       , '&shochu=1']
      ['hubot wine     西新宿'         , '&wine=1']
      ['hubot wine  me   西新宿'       , '&wine=1']
      ['hubot ワイン     西新宿'       , '&wine=1']
      ['hubot ワイン  me   西新宿'     , '&wine=1']
      ['hubot karaoke     西新宿'      , '&karaoke=1']
      ['hubot karaoke  me   西新宿'    , '&karaoke=1']
      ['hubot カラオケ     西新宿'     , '&karaoke=1']
      ['hubot カラオケ  me   西新宿'   , '&karaoke=1']
      ['hubot midnight meal  西新宿'   , '&midnight_meal=1']
      ['hubot midnight meal me 西新宿' , '&midnight_meal=1']
      ['hubot 夜食  西新宿'            , '&midnight_meal=1']
      ['hubot 夜食 me 西新宿'          , '&midnight_meal=1']
      ['hubot free  drink  西新宿'     , '&free_drink=1']
      ['hubot free  drink me  西新宿'  , '&free_drink=1']
      ['hubot 飲み放題  西新宿'        , '&free_drink=1']
      ['hubot 飲み放題  me  西新宿'    , '&free_drink=1']
      ['hubot free  food  西新宿'      , '&free_food=1']
      ['hubot free  food me  西新宿'   , '&free_food=1']
      ['hubot 食べ放題  西新宿'        , '&free_food=1']
      ['hubot 食べ放題  me  西新宿'    , '&free_food=1']
    ].forEach ([msg, query], i)->
      it "responds to #{msg}", (done)->
        nock('http://webservice.recruit.co.jp')
          .get("/hotpepper/gourmet/v1/?key=fake-api-key&keyword=#{encodeURIComponent '西新宿'}&count=100&format=json#{query}")
          .reply 200, results:
            shop: [
              {
                name: "店舗名 #{i}"
                address: "東京都新宿区 #{i}"
                photo: { pc: { l: "http://imgfp.hotp.jp/path/to/#{i}.jpg" } }
                urls: { pc: "http://www.hotpepper.jp/path/to/store/#{i}" }
              }
            ]
        count = 0
        adapter.on 'send', (envelope, strings)->
          try
            expect(envelope.user.id).to.equal '1'
            expect(envelope.user.name).to.equal 'ngs'
            expect(envelope.user.room).to.equal '#mocha'
            expect(strings).to.have.length(1)
            expect(strings[0]).to.be.a 'string'
            expect(strings[0]).to.equal [
              "http://imgfp.hotp.jp/path/to/#{i}.jpg#.png"
              "店舗名 #{i}\n東京都新宿区 #{i}\nhttp://www.hotpepper.jp/path/to/store/#{i}"
            ][count]
            do done if ++count == 2
          catch e
            done e
        adapter.receive new TextMessage user, msg

