mongoose-visibility
===================

[![Build Status](https://travis-ci.org/keifukuda/mongoose-visibility.svg?branch=master)](https://travis-ci.org/keifukuda/mongoose-visibility)
[![Dependency Status](https://david-dm.org/keifukuda/mongoose-visibility.svg?theme=shields.io)](https://david-dm.org/keifukuda/mongoose-visibility)
[![devDependency Status](https://david-dm.org/keifukuda/mongoose-visibility/dev-status.svg?theme=shields.io)](https://david-dm.org/keifukuda/mongoose-visibility#info=devDependencies)

A Visibility plugin for [Mongoose](https://github.com/LearnBoost/mongoose)


Installation
------------

`npm install --save mongoose-visibility`


Usage
-----

```javascript
var User, attrs, mongoose, visibility, userSchema;

mongoose = require('mongoose');
visibility = require('mongoose-visibility');
mongoose.connect('mongodb://localhost/mongoose-checkit');

userSchema = new mongoose.Schema({
  username: String,
  password: String,
  profile: {
    nickname: String,
    firstname: String,
    lastname: String
  }
});

attrs = {
  username: 'keifukuda',
  password: 'userpass',
  profile: {
    nickname: 'KEIFUKUDA',
    firstname: 'Kei',
    lastname: 'Fukuda'
  }
};
```

### Visible

```javascript
userSchema.plugin(visibility, {
  visible: ['_id', 'username', 'profile.nickname']
});

//
// OR
//

userSchema.plugin visibility
userSchema.visibility = visible: ['_id', 'username', 'profile.nickname']


User = mongoose.model("User", userSchema);

User.create(attrs, function(err, user) {
  return console.log(user.toJSON());
  // => {
  //      _id: '53e66b9235cc7e7531e97421',
  //      username: 'keifukuda',
  //      profile: {
  //        nickname: 'KEIFUKUDA'
  //      }
  //    }
});
```

### Hidden

```javascript
userSchema.plugin(visibility, {
  hidden: ['__v', 'password', 'profile.firstname', 'profile.lastname']
});

//
// OR
//

userSchema.plugin visibility
userSchema.visibility = hidden: ['__v', 'password', 'profile.firstname', 'profile.lastname']


User = mongoose.model("User", userSchema);

User.create(attrs, function(err, user) {
  return console.log(user.toJSON());
  // => {
  //      _id: '53e66b9235cc7e7531e97421',
  //      username: 'keifukuda',
  //      profile: {
  //        nickname: 'KEIFUKUDA'
  //      }
  //    }
});
```

### Virtuals

```javascript
userSchema.set('toJSON', { virtuals: true });
userSchema.virtual('profile.fullname').get(function() {
  return this.profile.firstname + ' ' + this.profile.lastname;
});
userSchema.plugin(visibility, {visible: ['_id', 'username', 'profile.fullname']});

User = mongoose.model("User", userSchema);

User.create(attrs, function(err, user) {
  return console.log(user.toJSON());
  // => {
  //      _id: '53e66b9235cc7e7531e97421',
  //      username: 'keifukuda',
  //      profile: {
  //        fullname: 'Kei Fukuda'
  //      }
  //    }


//
// OR
//

userSchema.virtual('profile.fullname').get(function() {
  return this.profile.firstname + ' ' + this.profile.lastname;
});
userSchema.plugin(visibility, {visible: ['_id', 'username', 'profile.fullname']});

User = mongoose.model("User", userSchema);

User.create(attrs, function(err, user) {
  return console.log(user.toJSON({virtuals: true, transform: true}));
  // => {
  //      _id: '53e66b9235cc7e7531e97421',
  //      username: 'keifukuda',
  //      profile: {
  //        fullname: 'Kei Fukuda'
  //      }
  //    }
```
