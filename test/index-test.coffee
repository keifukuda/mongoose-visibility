assert = require 'power-assert'
mongoose = require 'mongoose'
visibility = require '../'

mongoose.connect 'mongodb://localhost/mongoose-visibility'

mongoose.connection.once 'error', (err) ->
  console.log "MongoDB connection error: #{err}"
  process.exit(1)

attrs =
  username:
    type: String
    default: 'Kei Fukuda'

  email:
    public:
      type: [String]
      default: ['kei@dea.jp']
    private:
      type: [String]
      default: ['kei+private@dea.jp']

  password:
    type: String
    default: 'userpass'

  profile:
    nickname:
      type: String
      default: 'KEIFUKUDA'

    firstname:
      type: String
      default: 'Kei'

    lastname:
      type: String
      default: 'Fukuda'



visibleSchema = new mongoose.Schema attrs
visibleSchema.plugin visibility, visible: ['_id', 'username', 'email.public', 'profile']
Visible = mongoose.model 'Visible', visibleSchema

hiddenSchema = new mongoose.Schema attrs
hiddenSchema.plugin visibility, hidden: ['email.private', 'password', 'profile.firstname', 'profile.lastname']
Hidden = mongoose.model 'Hidden', hiddenSchema

mixedSchema = new mongoose.Schema attrs
mixedSchema.plugin visibility, visible: ['username', 'email', 'profile.nickname'], hidden: ['email.private', 'password']
Mixed = mongoose.model 'Mixed', mixedSchema

noneSchema = new mongoose.Schema attrs
noneSchema.plugin visibility
None = mongoose.model 'None', noneSchema

virtualSchema = new mongoose.Schema attrs
virtualSchema.set 'toJSON', virtuals: true
virtualSchema.plugin visibility, visible: ['username', 'profile.fullname']
virtualSchema.virtual('profile.fullname').get -> @profile.firstname + ' ' + @profile.lastname
Virtual = mongoose.model 'Virtual', virtualSchema

afterVirtualSchema = new mongoose.Schema attrs
afterVirtualSchema.plugin visibility, visible: ['username', 'profile.fullname']
afterVirtualSchema.virtual('profile.fullname').get -> @profile.firstname + ' ' + @profile.lastname
AfterVirtual = mongoose.model 'AfterVirtual', afterVirtualSchema

advancedSchema = new mongoose.Schema attrs
advancedSchema.plugin visibility
Advanced = mongoose.model 'Advanced', advancedSchema


describe 'Mongoose Visibility Plugin', ->

  describe 'Visible Schema', ->

    it 'should be obtained visible only attributes', (done) ->

      Visible.create null, (err, document) ->
        json = document.toJSON()
        assert json._id
        assert json.username
        assert json.email.public
        assert json.profile
        assert json.profile.nickname
        assert json.profile.firstname
        assert json.profile.lastname

        assert json.email.private is undefined
        assert json.password is undefined
        done()

  describe 'Hidden Schema', ->

    it 'should not be obtained hidden attributes.', (done) ->

      Hidden.create null, (err, document) ->
        json = document.toJSON()
        assert json._id
        assert json.__v is 0
        assert json.username
        assert json.email.public
        assert json.profile.nickname

        assert json.email.private is undefined
        assert json.password is undefined
        assert json.profile.firstname is undefined
        assert json.profile.lastname is undefined

        done()


  describe 'Mixed Schema', ->

    it 'should not be obtained hidden attributes and should be obtained visible only attributes.', (done) ->

      Mixed.create null, (err, document) ->
        json = document.toJSON()
        assert json.username
        assert json.email.public
        assert json.profile.nickname

        assert json.email.private is undefined
        assert json.password is undefined
        assert json.profile.firstname is undefined
        assert json.profile.lastname is undefined

        done()


  describe 'Virtual Schema', ->

    it 'should be can get virtual value.', (done) ->

      Virtual.create null, (err, document) ->
        json = document.toJSON()
        assert json.username
        assert json.profile.fullname

        assert json.email is undefined
        assert json.password is undefined
        assert json.profile.nickname is undefined
        assert json.profile.firstname is undefined
        assert json.profile.lastname is undefined

        done()

  describe 'After Virtual Schema', ->

    it 'should be can get virtual value.', (done) ->

      AfterVirtual.create null, (err, document) ->
        json = document.toJSON(virtuals: true, transform: true)
        assert json.username
        assert json.profile.fullname

        assert json.email is undefined
        assert json.password is undefined
        assert json.profile.nickname is undefined
        assert json.profile.firstname is undefined
        assert json.profile.lastname is undefined
        done()


  describe 'None Schema', ->

    it 'should be can get all attributes.', (done) ->

      None.create null, (err, document) ->
        json = document.toJSON()
        assert json._id
        assert json.__v is 0
        assert json.username
        assert json.email
        assert json.profile
        assert json.password
        done()


  describe 'Advanced Schema', ->

    it 'should be can set the value later.', (done) ->

      Advanced.schema.visibility = visible: ['username', 'email.public', 'profile']
      Advanced.create null, (err, document) ->
        json = document.toJSON()
        assert json.username
        assert json.email.public
        assert json.profile.nickname
        assert json.profile.firstname
        assert json.profile.lastname

        assert json.email.private is undefined
        assert json.password is undefined

        done()
