_ = require 'lodash'
flat = require 'flat'
flatten = flat.flatten
unflatten = flat.unflatten

module.exports = (schema, options) ->

  schema.options.toJSON ||= {}
  schema.visibility ||= {}

  if options
    schema.visibility = options

  if schema.visibility.virtuals
    schema.options.toJSON.virtuals = true

  schema.options.toJSON.transform = (document, object, options) ->

    visible = schema.visibility.visible
    hidden = schema.visibility.hidden

    if visible or hidden

      object._id = object._id.toString()
      flat = flatten object

      if visible
        flat = _.pick flat, visible

        nest = {}
        for key, value of flatten(object)
          for attr in visible
            regex = new RegExp attr + '\.'
            if regex.test key
              nest[key] = value

        flat = _.merge flat, nest


      if hidden
        flat = _.omit flat, hidden
        for key, value of flat
          for attr in hidden
            regex = new RegExp attr + '\.'
            if regex.test key
              delete flat[key]

      unflatten flat

    else
      object
